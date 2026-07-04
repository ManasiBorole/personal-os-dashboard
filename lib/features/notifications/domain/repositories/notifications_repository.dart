import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';

abstract interface class NotificationsRepository {
  Future<List<AppNotification>> getNotifications({required String userId});

  Future<AppNotification> createNotification({
    required String userId,
    required CreateNotificationParams params,
  });

  Future<AppNotification> markAsRead({required String id});

  Future<void> markAllAsRead({required String userId});

  Future<void> deleteNotification({required String id});

  Future<int> getUnreadCount({required String userId});

  Future<bool> existsByDedupeKey({
    required String userId,
    required String dedupeKey,
  });
}
