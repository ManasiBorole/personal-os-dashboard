import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';

/// Parameters for creating a notification.
final class CreateNotificationParams {
  const CreateNotificationParams({
    required this.type,
    required this.title,
    required this.body,
    required this.entityId,
    required this.entityType,
    required this.routePath,
    required this.scheduledAt,
    required this.dedupeKey,
  });

  final NotificationType type;
  final String title;
  final String body;
  final String? entityId;
  final String? entityType;
  final String? routePath;
  final DateTime? scheduledAt;
  final String dedupeKey;
}
