import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_form_state.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/domain/usecases/task_usecases.dart';

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(tasksRepositoryProvider));
});

final getTaskByIdUseCaseProvider = Provider<GetTaskByIdUseCase>((ref) {
  return GetTaskByIdUseCase(ref.watch(tasksRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(tasksRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(tasksRepositoryProvider));
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return CompleteTaskUseCase(ref.watch(tasksRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(tasksRepositoryProvider));
});

final tasksSearchQueryProvider = StateProvider<String>((ref) => '');

final tasksFilterProvider =
    StateProvider<TaskFilter>((ref) => TaskFilter.empty);

final tasksSortProvider = StateProvider<TaskSortOption>(
  (ref) => TaskSortOption.recentlyUpdated,
);

final tasksListProvider =
    AsyncNotifierProvider<TasksListController, List<Task>>(
  TasksListController.new,
);

class TasksListController extends AsyncNotifier<List<Task>> {
  String? _projectId;

  String? get projectId => _projectId;

  @override
  Future<List<Task>> build() => _loadTasks();

  void setProjectFilter(String? projectId) {
    _projectId = projectId;
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadTasks);
  }

  Future<List<Task>> _loadTasks() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getTasksUseCaseProvider).call(
          (userId: userId, projectId: _projectId),
        );

    return result.when(
      success: (tasks) => tasks,
      onFailure: (failure) {
        throw sl<ErrorHandler>().getUserMessage(failure);
      },
    );
  }

  Future<bool> completeTask(String id) async {
    final result = await ref.read(completeTaskUseCaseProvider).call(id);
    return result.when(
      success: (task) {
        _invalidateRelated(task.projectId);
        refresh();
        return true;
      },
      onFailure: (_) => false,
    );
  }

  Future<bool> deleteTask(String id, {String? projectId}) async {
    final result = await ref.read(deleteTaskUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        _invalidateRelated(projectId);
        refresh();
        return true;
      },
      onFailure: (_) => false,
    );
  }

  void _invalidateRelated(String? projectId) {
    ref.invalidate(dashboardSummaryProvider);
    if (projectId != null) {
      ref.invalidate(projectDashboardProvider(projectId));
    }
  }
}

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksListProvider).maybeWhen(
        data: (value) => value,
        orElse: () => const <Task>[],
      );
  final query = ref.watch(tasksSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(tasksFilterProvider);
  final sort = ref.watch(tasksSortProvider);

  var result = tasks.where((task) {
    final matchesSearch = query.isEmpty ||
        task.title.toLowerCase().contains(query) ||
        task.description.toLowerCase().contains(query) ||
        (task.projectName?.toLowerCase().contains(query) ?? false);

    final matchesStatus =
        filter.status == null || task.status == filter.status;
    final matchesPriority =
        filter.priority == null || task.priority == filter.priority;
    final matchesProject =
        filter.projectId == null || task.projectId == filter.projectId;

    return matchesSearch &&
        matchesStatus &&
        matchesPriority &&
        matchesProject;
  }).toList();

  result = List<Task>.from(result)..sort((a, b) => _compareTasks(a, b, sort));

  return result;
});

int _compareTasks(Task a, Task b, TaskSortOption sort) {
  return switch (sort) {
    TaskSortOption.recentlyUpdated => b.updatedAt.compareTo(a.updatedAt),
    TaskSortOption.dueDateAsc => _compareDueDates(a.dueDate, b.dueDate),
    TaskSortOption.priorityDesc =>
      _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
    TaskSortOption.titleAsc =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    TaskSortOption.statusAsc =>
      a.status.label.compareTo(b.status.label),
  };
}

int _compareDueDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

int _priorityRank(TaskPriority priority) => switch (priority) {
      TaskPriority.high => 3,
      TaskPriority.medium => 2,
      TaskPriority.low => 1,
    };

final taskFormControllerProvider =
    NotifierProvider<TaskFormController, TaskFormState>(TaskFormController.new);

class TaskFormController extends Notifier<TaskFormState> {
  @override
  TaskFormState build() => const TaskFormIdle();

  Future<bool> createTask(CreateTaskParams params) async {
    state = const TaskFormLoading();

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createTaskUseCaseProvider).call(
          CreateTaskRequest(userId: userId, task: params),
        );

    return result.when(
      success: (_) {
        state = const TaskFormSuccess(message: 'Task created successfully.');
        ref.invalidate(tasksListProvider);
        ref.invalidate(dashboardSummaryProvider);
        if (params.projectId != null) {
          ref.invalidate(projectDashboardProvider(params.projectId!));
        }
        return true;
      },
      onFailure: (failure) {
        state = TaskFormError(sl<ErrorHandler>().getUserMessage(failure));
        return false;
      },
    );
  }

  Future<bool> updateTask(UpdateTaskParams params) async {
    state = const TaskFormLoading();

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateTaskUseCaseProvider).call(
          UpdateTaskRequest(userId: userId, task: params),
        );

    return result.when(
      success: (task) {
        state = const TaskFormSuccess(message: 'Task updated successfully.');
        ref.invalidate(tasksListProvider);
        ref.invalidate(dashboardSummaryProvider);
        if (task.projectId != null) {
          ref.invalidate(projectDashboardProvider(task.projectId!));
        }
        return true;
      },
      onFailure: (failure) {
        state = TaskFormError(sl<ErrorHandler>().getUserMessage(failure));
        return false;
      },
    );
  }

  Future<bool> deleteTask(String id, {String? projectId}) async {
    state = const TaskFormLoading();

    final result = await ref.read(deleteTaskUseCaseProvider).call(id);

    return result.when(
      success: (_) {
        state = const TaskFormSuccess(message: 'Task deleted.');
        ref.invalidate(tasksListProvider);
        ref.invalidate(dashboardSummaryProvider);
        if (projectId != null) {
          ref.invalidate(projectDashboardProvider(projectId));
        }
        return true;
      },
      onFailure: (failure) {
        state = TaskFormError(sl<ErrorHandler>().getUserMessage(failure));
        return false;
      },
    );
  }

  void clearStatus() => state = const TaskFormIdle();
}

final taskDetailProvider = FutureProvider.family<Task, String>((ref, id) async {
  final result = await ref.read(getTaskByIdUseCaseProvider).call(id);

  return result.when(
    success: (task) => task,
    onFailure: (failure) {
      throw sl<ErrorHandler>().getUserMessage(failure);
    },
  );
});
