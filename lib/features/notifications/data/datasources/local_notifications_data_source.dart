import 'package:personal_os_dashboard/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/data/models/notification_model.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';

final class LocalNotificationsDataSource implements NotificationsDataSource {
  final Map<String, NotificationModel> _notifications = {};

  LocalNotificationsDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final samples = [
      NotificationModel(
        id: 'notif-local-1',
        userId: userId,
        type: NotificationType.meetingReminder.name,
        title: 'Product sync starting soon',
        body: 'Your meeting starts in 15 minutes at Zoom.',
        entityId: 'meet-local-1',
        entityType: 'meeting',
        routePath: '/meetings/meet-local-1',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
        scheduledAt: DateTime(now.year, now.month, now.day, 13, 45),
        dedupeKey: 'meeting_reminder_meet-local-1',
      ),
      NotificationModel(
        id: 'notif-local-2',
        userId: userId,
        type: NotificationType.taskReminder.name,
        title: 'Task reminder: Weekly review',
        body: 'Your task is due tomorrow.',
        entityId: 'task-local-3',
        entityType: 'task',
        routePath: '/tasks/task-local-3/edit',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        scheduledAt: now.add(const Duration(days: 1, hours: 9)),
        dedupeKey: 'task_reminder_task-local-3',
      ),
    ];

    for (final notification in samples) {
      _notifications[notification.id] = notification;
    }
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    return _notifications.values
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<NotificationModel> createNotification({
    required String userId,
    required CreateNotificationParams params,
  }) async {
    final id = 'notif-local-${DateTime.now().microsecondsSinceEpoch}';
    final model = NotificationModel.fromParams(
      id: id,
      userId: userId,
      params: params,
    );
    _notifications[id] = model;
    return model;
  }

  @override
  Future<NotificationModel> markAsRead({required String id}) async {
    final existing = _notifications[id];
    if (existing == null) throw StateError('Notification not found');
    final updated = existing.copyWith(isRead: true);
    _notifications[id] = updated;
    return updated;
  }

  @override
  Future<void> markAllAsRead({required String userId}) async {
    for (final entry in _notifications.entries) {
      if (entry.value.userId == userId && !entry.value.isRead) {
        _notifications[entry.key] = entry.value.copyWith(isRead: true);
      }
    }
  }

  @override
  Future<void> deleteNotification({required String id}) async {
    _notifications.remove(id);
  }

  @override
  Future<bool> existsByDedupeKey({
    required String userId,
    required String dedupeKey,
  }) async {
    return _notifications.values.any(
      (n) => n.userId == userId && n.dedupeKey == dedupeKey,
    );
  }
}
