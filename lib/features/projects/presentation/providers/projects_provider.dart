import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_form_state.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';
import 'package:personal_os_dashboard/features/projects/domain/usecases/project_usecases.dart';

final getProjectsUseCaseProvider = Provider<GetProjectsUseCase>((ref) {
  return GetProjectsUseCase(ref.watch(projectsRepositoryProvider));
});

final getProjectByIdUseCaseProvider = Provider<GetProjectByIdUseCase>((ref) {
  return GetProjectByIdUseCase(ref.watch(projectsRepositoryProvider));
});

final getProjectDashboardUseCaseProvider =
    Provider<GetProjectDashboardUseCase>((ref) {
  return GetProjectDashboardUseCase(ref.watch(projectsRepositoryProvider));
});

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(ref.watch(projectsRepositoryProvider));
});

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>((ref) {
  return UpdateProjectUseCase(ref.watch(projectsRepositoryProvider));
});

final deleteProjectUseCaseProvider = Provider<DeleteProjectUseCase>((ref) {
  return DeleteProjectUseCase(ref.watch(projectsRepositoryProvider));
});

final projectsSearchQueryProvider = StateProvider<String>((ref) => '');

final projectsFilterProvider =
    StateProvider<ProjectFilter>((ref) => ProjectFilter.empty);

final projectsSortProvider = StateProvider<ProjectSortOption>(
  (ref) => ProjectSortOption.recentlyUpdated,
);

final projectsListProvider = AsyncNotifierProvider<ProjectsListController,
    List<Project>>(ProjectsListController.new);

class ProjectsListController extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Project>> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getProjectsUseCaseProvider).call(userId);
    return result.when(
      success: (projects) => projects,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final filteredProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(projectsListProvider).maybeWhen(
        data: (v) => v,
        orElse: () => const <Project>[],
      );
  final query = ref.watch(projectsSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(projectsFilterProvider);
  final sort = ref.watch(projectsSortProvider);

  var result = projects.where((p) {
    final matchesSearch = query.isEmpty ||
        p.name.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query) ||
        p.client.company.toLowerCase().contains(query) ||
        p.client.name.toLowerCase().contains(query);
    final matchesStatus = filter.status == null || p.status == filter.status;
    return matchesSearch && matchesStatus;
  }).toList();

  result.sort((a, b) => switch (sort) {
        ProjectSortOption.recentlyUpdated =>
          b.updatedAt.compareTo(a.updatedAt),
        ProjectSortOption.nameAsc =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        ProjectSortOption.nameDesc =>
          b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        ProjectSortOption.progressDesc => b.progress.compareTo(a.progress),
        ProjectSortOption.deadlineAsc => _compareDates(
            a.timeline.endDate,
            b.timeline.endDate,
          ),
        ProjectSortOption.budgetDesc =>
          b.budget.amount.compareTo(a.budget.amount),
      });

  return result;
});

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

final projectDashboardProvider =
    AsyncNotifierProvider.family<ProjectDashboardController, ProjectDashboard,
        String>(ProjectDashboardController.new);

class ProjectDashboardController
    extends FamilyAsyncNotifier<ProjectDashboard, String> {
  @override
  Future<ProjectDashboard> build(String projectId) => _load(projectId);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg));
  }

  Future<ProjectDashboard> _load(String projectId) async {
    final result =
        await ref.read(getProjectDashboardUseCaseProvider).call(projectId);
    return result.when(
      success: (dashboard) => dashboard,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final projectFormControllerProvider =
    NotifierProvider<ProjectFormController, ProjectFormState>(
  ProjectFormController.new,
);

class ProjectFormController extends Notifier<ProjectFormState> {
  @override
  ProjectFormState build() => const ProjectFormIdle();

  String get _userId => ref.read(currentUserProvider)?.id ?? 'local-user';

  Future<bool> create(CreateProjectParams params) async {
    state = const ProjectFormLoading();
    final result = await ref.read(createProjectUseCaseProvider).call(
          CreateProjectRequest(userId: _userId, project: params),
        );
    return result.when(
      success: (_) {
        state = const ProjectFormSuccess(message: 'Project created.');
        ref.invalidate(projectsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (f) {
        state = ProjectFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> update(UpdateProjectParams params) async {
    state = const ProjectFormLoading();
    final result = await ref.read(updateProjectUseCaseProvider).call(
          UpdateProjectRequest(userId: _userId, project: params),
        );
    return result.when(
      success: (_) {
        state = const ProjectFormSuccess(message: 'Project updated.');
        ref.invalidate(projectsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(projectDashboardProvider(params.id));
        return true;
      },
      onFailure: (f) {
        state = ProjectFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = const ProjectFormLoading();
    final result = await ref.read(deleteProjectUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const ProjectFormSuccess(message: 'Project deleted.');
        ref.invalidate(projectsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (f) {
        state = ProjectFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<void> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  }) async {
    await ref.read(projectsRepositoryProvider).addMember(
          projectId: projectId,
          name: name,
          email: email,
          role: role,
        );
    ref.invalidate(projectDashboardProvider(projectId));
  }

  Future<void> addNote({
    required String projectId,
    required String title,
    required String content,
  }) async {
    await ref.read(projectsRepositoryProvider).addNote(
          projectId: projectId,
          title: title,
          content: content,
        );
    ref.invalidate(projectDashboardProvider(projectId));
  }

  void clearStatus() => state = const ProjectFormIdle();
}
