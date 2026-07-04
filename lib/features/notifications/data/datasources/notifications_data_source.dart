import 'package:personal_os_dashboard/features/notifications/data/models/notification_model.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';

abstract interface class NotificationsDataSource {
  Future<List<NotificationModel>> getNotifications({required String userId});

  Future<NotificationModel> createNotification({
    required String userId,
    required CreateNotificationParams params,
  });

  Future<NotificationModel> markAsRead({required String id});

  Future<void> markAllAsRead({required String userId});

  Future<void> deleteNotification({required String id});

  Future<bool> existsByDedupeKey({
    required String userId,
    required String dedupeKey,
  });
}
