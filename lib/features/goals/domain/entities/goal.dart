import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Goal priority levels.
enum GoalPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const GoalPriority(this.label);

  final String label;

  static GoalPriority fromString(String? value) {
    return GoalPriority.values.firstWhere(
      (priority) => priority.name == value?.toLowerCase(),
      orElse: () => GoalPriority.medium,
    );
  }
}

/// Goal lifecycle status.
enum GoalStatus {
  active('Active'),
  completed('Completed'),
  paused('Paused'),
  cancelled('Cancelled');

  const GoalStatus(this.label);

  final String label;

  static GoalStatus fromString(String? value) {
    return GoalStatus.values.firstWhere(
      (status) => status.name == value?.toLowerCase(),
      orElse: () => GoalStatus.active,
    );
  }
}

/// Common goal categories.
enum GoalCategory {
  personal('Personal'),
  career('Career'),
  health('Health'),
  finance('Finance'),
  learning('Learning'),
  other('Other');

  const GoalCategory(this.label);

  final String label;

  static GoalCategory fromString(String? value) {
    return GoalCategory.values.firstWhere(
      (category) => category.name == value?.toLowerCase(),
      orElse: () => GoalCategory.other,
    );
  }
}

/// Domain entity representing a user goal.
final class Goal extends Entity {
  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.deadline,
    required this.progress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final DateTime? deadline;
  final double progress;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get progressPercent => (progress * 100).round();

  bool get isOverdue {
    if (deadline == null || status == GoalStatus.completed) {
      return false;
    }

    return deadline!.isBefore(DateTime.now());
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    GoalCategory? category,
    GoalPriority? priority,
    DateTime? deadline,
    double? progress,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDeadline = false,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      progress: progress ?? this.progress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        category,
        priority,
        deadline,
        progress,
        status,
        createdAt,
        updatedAt,
      ];
}
