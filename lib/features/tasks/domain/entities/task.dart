import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Task priority levels.
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.label);

  final String label;

  static TaskPriority fromString(String? value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name == value?.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Task lifecycle status.
enum TaskStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  const TaskStatus(this.label);

  final String label;

  static TaskStatus fromString(String? value) {
    final normalized =
        value?.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    return TaskStatus.values.firstWhere(
      (s) =>
          s.name == normalized ||
          s.storageValue == normalized ||
          s.name.toLowerCase().replaceAll('_', '') ==
              normalized?.replaceAll('_', ''),
      orElse: () => TaskStatus.pending,
    );
  }

  String get storageValue => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.completed => 'completed',
        TaskStatus.cancelled => 'cancelled',
      };
}

/// Checklist item within a task.
final class ChecklistItem extends Entity {
  const ChecklistItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  ChecklistItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

/// Domain task entity with checklist and subtasks.
final class Task extends Entity {
  const Task({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.parentTaskId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.reminderAt,
    required this.checklist,
    required this.subtasks,
    required this.projectName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? projectId;
  final String? parentTaskId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<ChecklistItem> checklist;
  final List<Task> subtasks;
  final String? projectName;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == TaskStatus.completed;

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  double get checklistProgress {
    if (checklist.isEmpty) return 0;
    final done = checklist.where((c) => c.isCompleted).length;
    return done / checklist.length;
  }

  bool get isSubtask => parentTaskId != null;

  Task copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? parentTaskId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? reminderAt,
    List<ChecklistItem>? checklist,
    List<Task>? subtasks,
    String? projectName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearProjectId = false,
    bool clearDueDate = false,
    bool clearReminder = false,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      parentTaskId: parentTaskId ?? this.parentTaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      checklist: checklist ?? this.checklist,
      subtasks: subtasks ?? this.subtasks,
      projectName: projectName ?? this.projectName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        projectId,
        parentTaskId,
        title,
        description,
        status,
        priority,
        dueDate,
        reminderAt,
        checklist,
        subtasks,
        projectName,
        createdAt,
        updatedAt,
      ];
}
