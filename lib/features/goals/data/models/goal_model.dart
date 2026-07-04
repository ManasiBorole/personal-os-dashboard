import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';

/// Data transfer object for goal persistence.
final class GoalModel {
  const GoalModel({
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
  final String category;
  final String priority;
  final DateTime? deadline;
  final double progress;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      priority: json['priority']?.toString() ?? 'medium',
      deadline: _parseDate(json['deadline']),
      progress: _parseProgress(json['progress']),
      status: json['status']?.toString() ?? 'active',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'progress': (progress * 100).round(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final data = Map<String, dynamic>.from(toJson());
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    return data;
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'progress': (progress * 100).round(),
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Goal toEntity() {
    return Goal(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: GoalCategory.fromString(category),
      priority: GoalPriority.fromString(priority),
      deadline: deadline,
      progress: progress,
      status: GoalStatus.fromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      userId: goal.userId,
      title: goal.title,
      description: goal.description,
      category: goal.category.name,
      priority: goal.priority.name,
      deadline: goal.deadline,
      progress: goal.progress,
      status: goal.status.name,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    );
  }

  static double _parseProgress(dynamic value) {
    if (value is num) {
      final progress = value.toDouble();
      return progress > 1 ? progress / 100 : progress;
    }
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
