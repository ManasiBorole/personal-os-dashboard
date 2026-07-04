import 'package:personal_os_dashboard/core/notifications/fcm_service.dart';
import 'package:personal_os_dashboard/core/notifications/local_notification_service.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/core/constants/storage_constants.dart';
import 'package:personal_os_dashboard/features/notifications/data/services/reminder_scheduler_service.dart';

/// Coordinates FCM, local notifications, and reminder scheduling.
final class NotificationCoordinator {
  NotificationCoordinator({
    required FcmService fcmService,
    required LocalNotificationService localNotificationService,
    required ReminderSchedulerService reminderScheduler,
    required StorageHelper storageHelper,
  })  : _fcmService = fcmService,
        _localNotificationService = localNotificationService,
        _reminderScheduler = reminderScheduler,
        _storageHelper = storageHelper;

  final FcmService _fcmService;
  final LocalNotificationService _localNotificationService;
  final ReminderSchedulerService _reminderScheduler;
  final StorageHelper _storageHelper;

  Future<void> initialize({
    required String userId,
    void Function(String? routePath)? onNotificationTap,
  }) async {
    await _fcmService.initialize(
      userId: userId,
      onNotificationTap: onNotificationTap,
    );
    await _localNotificationService.initialize();
    await syncReminders(userId: userId);
  }

  Future<void> syncReminders({required String userId}) async {
    final created = await _reminderScheduler.syncReminders(userId: userId);
    if (!_arePushNotificationsEnabled()) return;

    for (final notification in created) {
      await _localNotificationService.showNotification(notification);
    }
  }

  bool _arePushNotificationsEnabled() {
    return _storageHelper.readSetting<bool>(
          StorageConstants.notificationsEnabledKey,
        ) ??
        true;
  }
}
