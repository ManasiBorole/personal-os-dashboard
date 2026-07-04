import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';

final class NotificationModel {
  const NotificationModel({
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
  final String type;
  final String title;
  final String body;
  final String? entityId;
  final String? entityType;
  final String? routePath;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String dedupeKey;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: json['type']?.toString() ?? NotificationType.taskReminder.name,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      entityId: json['entity_id']?.toString(),
      entityType: json['entity_type']?.toString(),
      routePath: json['route_path']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      scheduledAt: _parseDate(json['scheduled_at']),
      dedupeKey: json['dedupe_key']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'entity_id': entityId,
      'entity_type': entityType,
      'route_path': routePath,
      'is_read': isRead,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'dedupe_key': dedupeKey,
      'created_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'body': body,
      'entity_id': entityId,
      'entity_type': entityType,
      'route_path': routePath,
      'is_read': isRead,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'dedupe_key': dedupeKey,
    };
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      userId: userId,
      type: NotificationType.fromString(type),
      title: title,
      body: body,
      entityId: entityId,
      entityType: entityType,
      routePath: routePath,
      isRead: isRead,
      createdAt: createdAt,
      scheduledAt: scheduledAt,
      dedupeKey: dedupeKey,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
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
    return NotificationModel(
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

  static NotificationModel fromParams({
    required String id,
    required String userId,
    required CreateNotificationParams params,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: params.type.name,
      title: params.title,
      body: params.body,
      entityId: params.entityId,
      entityType: params.entityType,
      routePath: params.routePath,
      isRead: false,
      createdAt: DateTime.now(),
      scheduledAt: params.scheduledAt,
      dedupeKey: params.dedupeKey,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
