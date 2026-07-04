import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_form_state.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_sort_option.dart';
import 'package:personal_os_dashboard/features/goals/domain/usecases/goal_usecases.dart';

// Use cases

final getGoalsUseCaseProvider = Provider<GetGoalsUseCase>((ref) {
  return GetGoalsUseCase(ref.watch(goalsRepositoryProvider));
});

final getGoalByIdUseCaseProvider = Provider<GetGoalByIdUseCase>((ref) {
  return GetGoalByIdUseCase(ref.watch(goalsRepositoryProvider));
});

final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  return CreateGoalUseCase(ref.watch(goalsRepositoryProvider));
});

final updateGoalUseCaseProvider = Provider<UpdateGoalUseCase>((ref) {
  return UpdateGoalUseCase(ref.watch(goalsRepositoryProvider));
});

final deleteGoalUseCaseProvider = Provider<DeleteGoalUseCase>((ref) {
  return DeleteGoalUseCase(ref.watch(goalsRepositoryProvider));
});

// List state

final goalsSearchQueryProvider = StateProvider<String>((ref) => '');

final goalsFilterProvider = StateProvider<GoalFilter>((ref) => GoalFilter.empty);

final goalsSortProvider = StateProvider<GoalSortOption>(
  (ref) => GoalSortOption.recentlyUpdated,
);

final goalsListProvider =
    AsyncNotifierProvider<GoalsListController, List<Goal>>(GoalsListController.new);

class GoalsListController extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() => _loadGoals();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadGoals);
  }

  Future<List<Goal>> _loadGoals() async {
    final userId = _resolveUserId();
    final result = await ref.read(getGoalsUseCaseProvider).call(userId);

    return result.when(
      success: (goals) => goals,
      onFailure: (failure) {
        throw sl<ErrorHandler>().getUserMessage(failure);
      },
    );
  }

  String _resolveUserId() {
    final user = ref.read(currentUserProvider);
    return user?.id ?? 'local-user';
  }
}

/// Applies search, filter, and sort to the loaded goals list.
final filteredGoalsProvider = Provider<List<Goal>>((ref) {
  final goalsAsync = ref.watch(goalsListProvider);
  final query = ref.watch(goalsSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(goalsFilterProvider);
  final sort = ref.watch(goalsSortProvider);

  final goals = goalsAsync.maybeWhen(
    data: (value) => value,
    orElse: () => const <Goal>[],
  );

  var result = goals.where((goal) {
    final matchesSearch = query.isEmpty ||
        goal.title.toLowerCase().contains(query) ||
        goal.description.toLowerCase().contains(query) ||
        goal.category.label.toLowerCase().contains(query);

    final matchesStatus = filter.status == null || goal.status == filter.status;
    final matchesCategory =
        filter.category == null || goal.category == filter.category;
    final matchesPriority =
        filter.priority == null || goal.priority == filter.priority;

    return matchesSearch && matchesStatus && matchesCategory && matchesPriority;
  }).toList();

  result = List<Goal>.from(result)
    ..sort((a, b) => _compareGoals(a, b, sort));

  return result;
});

int _compareGoals(Goal a, Goal b, GoalSortOption sort) {
  return switch (sort) {
    GoalSortOption.recentlyUpdated => b.updatedAt.compareTo(a.updatedAt),
    GoalSortOption.deadlineAsc => _compareDeadlines(a.deadline, b.deadline),
    GoalSortOption.deadlineDesc => _compareDeadlines(b.deadline, a.deadline),
    GoalSortOption.titleAsc => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    GoalSortOption.titleDesc => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
    GoalSortOption.progressAsc => a.progress.compareTo(b.progress),
    GoalSortOption.progressDesc => b.progress.compareTo(a.progress),
    GoalSortOption.priorityDesc =>
      _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
  };
}

int _compareDeadlines(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

int _priorityRank(GoalPriority priority) => switch (priority) {
      GoalPriority.high => 3,
      GoalPriority.medium => 2,
      GoalPriority.low => 1,
    };

// Form controller

final goalFormControllerProvider =
    NotifierProvider<GoalFormController, GoalFormState>(GoalFormController.new);

class GoalFormController extends Notifier<GoalFormState> {
  @override
  GoalFormState build() => const GoalFormIdle();

  Future<bool> createGoal(CreateGoalParams params) async {
    state = const GoalFormLoading();

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createGoalUseCaseProvider).call(
          CreateGoalRequest(userId: userId, goal: params),
        );

    return result.when(
      success: (_) {
        state = const GoalFormSuccess(message: 'Goal created successfully.');
        ref.invalidate(goalsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (failure) {
        state = GoalFormError(sl<ErrorHandler>().getUserMessage(failure));
        return false;
      },
    );
  }

  Future<bool> updateGoal(UpdateGoalParams params) async {
    state = const GoalFormLoading();

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateGoalUseCaseProvider).call(
          UpdateGoalRequest(userId: userId, goal: params),
        );

    return result.when(
      success: (_) {
        state = const GoalFormSuccess(message: 'Goal updated successfully.');
        ref.invalidate(goalsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (failure) {
        state = GoalFormError(sl<ErrorHandler>().getUserMessage(failure));
        return false;
      },
    );
  }

  Future<bool> deleteGoal(String id) async {
    state = const GoalFormLoading();

    final result = await ref.read(deleteGoalUseCaseProvider).call(id);

    return result.when(
      success: (_) {
        state = const GoalFormSuccess(message: 'Goal deleted.');
        ref.invalidate(goalsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (failure) {
        state = GoalFormError(sl<ErrorHandler>().getUserMessage(failure));
        return false;
      },
    );
  }

  void clearStatus() => state = const GoalFormIdle();
}

final goalDetailProvider =
    FutureProvider.family<Goal, String>((ref, id) async {
  final result = await ref.read(getGoalByIdUseCaseProvider).call(id);

  return result.when(
    success: (goal) => goal,
    onFailure: (failure) {
      throw sl<ErrorHandler>().getUserMessage(failure);
    },
  );
});
