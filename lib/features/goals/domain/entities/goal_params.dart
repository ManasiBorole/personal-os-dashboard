import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';

/// Parameters for creating a new goal.
final class CreateGoalParams {
  const CreateGoalParams({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.deadline,
    required this.progress,
    required this.status,
  });

  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime? deadline;
  final double progress;
  final String status;
}

/// Parameters for updating an existing goal.
final class UpdateGoalParams {
  const UpdateGoalParams({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.deadline,
    required this.progress,
    required this.status,
    this.clearDeadline = false,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime? deadline;
  final double progress;
  final String status;
  final bool clearDeadline;
}

/// Filter criteria for goals list.
final class GoalFilter {
  const GoalFilter({
    this.status,
    this.category,
    this.priority,
  });

  final GoalStatus? status;
  final GoalCategory? category;
  final GoalPriority? priority;

  static const GoalFilter empty = GoalFilter();

  GoalFilter copyWith({
    GoalStatus? status,
    GoalCategory? category,
    GoalPriority? priority,
    bool clearStatus = false,
    bool clearCategory = false,
    bool clearPriority = false,
  }) {
    return GoalFilter(
      status: clearStatus ? null : (status ?? this.status),
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }

  bool get hasActiveFilters =>
      status != null || category != null || priority != null;
}
