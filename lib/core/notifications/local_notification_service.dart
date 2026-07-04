import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';

/// Displays system notifications while the app is in the foreground.
final class LocalNotificationService {
  LocalNotificationService(this._logger);

  final AppLogger _logger;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      const androidChannel = AndroidNotificationChannel(
        'personal_os_reminders',
        'Reminders',
        description: 'Task, meeting, goal, and birthday reminders',
        importance: Importance.high,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      _initialized = true;
      _logger.info('LocalNotificationService initialized');
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Local notifications unavailable',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> showNotification(AppNotification notification) async {
    if (!_initialized) return;

    try {
      await _plugin.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'personal_os_reminders',
            'Reminders',
            channelDescription:
                'Task, meeting, goal, and birthday reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: notification.routePath,
      );
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Failed to show local notification',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
  }
}
