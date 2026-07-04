import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';

/// Parameters for creating a task.
final class CreateTaskParams {
  const CreateTaskParams({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.parentTaskId,
    required this.dueDate,
    required this.reminderAt,
    required this.checklist,
    required this.subtasks,
  });

  final String title;
  final String description;
  final String status;
  final String priority;
  final String? projectId;
  final String? parentTaskId;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<ChecklistItem> checklist;
  final List<String> subtasks;
}

/// Parameters for updating a task.
final class UpdateTaskParams {
  const UpdateTaskParams({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.dueDate,
    required this.reminderAt,
    required this.checklist,
    required this.subtasks,
    this.clearProjectId = false,
    this.clearDueDate = false,
    this.clearReminder = false,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? projectId;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<ChecklistItem> checklist;
  final List<String> subtasks;
  final bool clearProjectId;
  final bool clearDueDate;
  final bool clearReminder;
}

/// Filter for tasks list.
final class TaskFilter {
  const TaskFilter({
    this.status,
    this.priority,
    this.projectId,
  });

  final TaskStatus? status;
  final TaskPriority? priority;
  final String? projectId;

  static const TaskFilter empty = TaskFilter();

  TaskFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearProjectId = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
    );
  }

  bool get hasActiveFilters =>
      status != null || priority != null || projectId != null;
}

enum TaskSortOption {
  recentlyUpdated('Recently updated'),
  dueDateAsc('Due date (soonest)'),
  priorityDesc('Priority (high–low)'),
  titleAsc('Title (A–Z)'),
  statusAsc('Status');

  const TaskSortOption(this.label);

  final String label;
}
