import 'dart:convert';

import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';

final class TaskModel {
  const TaskModel({
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
    required this.createdAt,
    required this.updatedAt,
    this.projectName,
  });

  final String id;
  final String userId;
  final String? projectId;
  final String? parentTaskId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<ChecklistItem> checklist;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? projectName;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      parentTaskId: json['parent_task_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString() ?? 'medium',
      dueDate: _parseDate(json['due_date']),
      reminderAt: _parseDate(json['reminder_at']),
      checklist: _parseChecklist(json['checklist']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      projectName: json['project_name']?.toString(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'project_id': projectId,
      'parent_task_id': parentTaskId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
      'checklist': checklist.map(_checklistToJson).toList(),
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
      'checklist': checklist.map(_checklistToJson).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Task toEntity({List<Task> subtasks = const []}) {
    return Task(
      id: id,
      userId: userId,
      projectId: projectId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      status: TaskStatus.fromString(status),
      priority: TaskPriority.fromString(priority),
      dueDate: dueDate,
      reminderAt: reminderAt,
      checklist: checklist,
      subtasks: subtasks,
      projectName: projectName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<ChecklistItem> _parseChecklist(dynamic value) {
    if (value == null) return const [];
    List<dynamic> items;
    if (value is String) {
      items = jsonDecode(value) as List<dynamic>? ?? [];
    } else if (value is List) {
      items = value;
    } else {
      return const [];
    }
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return ChecklistItem(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        isCompleted: map['is_completed'] == true || map['isCompleted'] == true,
      );
    }).toList();
  }

  static Map<String, dynamic> _checklistToJson(ChecklistItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'is_completed': item.isCompleted,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
