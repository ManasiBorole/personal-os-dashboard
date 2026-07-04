import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Notification category for reminders and alerts.
enum NotificationType {
  taskReminder('Task Reminder'),
  meetingReminder('Meeting Reminder'),
  goalDeadline('Goal Deadline'),
  birthdayReminder('Birthday Reminder');

  const NotificationType(this.label);

  final String label;

  static NotificationType fromString(String? value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value?.replaceAll('-', '_'),
      orElse: () => NotificationType.taskReminder,
    );
  }
}

/// In-app notification shown in the notification center.
final class AppNotification extends Entity {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.entityId,
    required this.entityType,
    required this.routePath,
    required this.isRead,
    required this.createdAt,
    required this.scheduledAt,
    required this.dedupeKey,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? entityId;
  final String? entityType;
  final String? routePath;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String dedupeKey;

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? entityId,
    String? entityType,
    String? routePath,
    bool? isRead,
    DateTime? createdAt,
    DateTime? scheduledAt,
    String? dedupeKey,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      routePath: routePath ?? this.routePath,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      dedupeKey: dedupeKey ?? this.dedupeKey,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        entityId,
        entityType,
        routePath,
        isRead,
        createdAt,
        scheduledAt,
        dedupeKey,
      ];
}
