import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:personal_os_dashboard/core/constants/storage_constants.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/notifications/local_notification_service.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';
import 'package:personal_os_dashboard/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:personal_os_dashboard/firebase_options.dart';

typedef NotificationTapHandler = void Function(String? routePath);

/// Firebase Cloud Messaging integration with graceful offline fallback.
final class FcmService {
  FcmService({
    required AppLogger logger,
    required StorageHelper storageHelper,
    required LocalNotificationService localNotificationService,
    NotificationsRepository? notificationsRepository,
  })  : _logger = logger,
        _storageHelper = storageHelper,
        _localNotificationService = localNotificationService,
        _notificationsRepository = notificationsRepository;

  final AppLogger _logger;
  final StorageHelper _storageHelper;
  final LocalNotificationService _localNotificationService;
  final NotificationsRepository? _notificationsRepository;

  FirebaseMessaging? _messaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  NotificationTapHandler? _onNotificationTap;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  String? get token => _storageHelper.readSetting<String>(
        StorageConstants.fcmTokenKey,
      );

  Future<void> initialize({
    NotificationTapHandler? onNotificationTap,
    String userId = 'local-user',
  }) async {
    if (_initialized) return;
    _onNotificationTap = onNotificationTap;

    await _localNotificationService.initialize();

    if (!DefaultFirebaseOptions.isConfigured) {
      _logger.info('Firebase not configured — using local notifications only');
      _initialized = true;
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _messaging = FirebaseMessaging.instance;

      final settings = await _messaging!.requestPermission();
      _logger.info('FCM permission: ${settings.authorizationStatus}');

      await _syncToken();

      _tokenRefreshSubscription =
          _messaging!.onTokenRefresh.listen((token) async {
        await _persistToken(token);
      });

      FirebaseMessaging.onMessage.listen((message) {
        unawaited(_handleForegroundMessage(message, userId));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = message.data['route_path'] as String?;
        _onNotificationTap?.call(route);
      });

      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        final route = initialMessage.data['route_path'] as String?;
        _onNotificationTap?.call(route);
      }

      _initialized = true;
      _logger.info('FCM initialized');
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'FCM initialization failed — local notifications only',
        error: error,
        stackTrace: stackTrace,
      );
      _initialized = true;
    }
  }

  Future<void> _syncToken() async {
    final messaging = _messaging;
    if (messaging == null) return;

    final token = await messaging.getToken();
    if (token != null) {
      await _persistToken(token);
    }
  }

  Future<void> _persistToken(String token) async {
    await _storageHelper.writeSetting(StorageConstants.fcmTokenKey, token);
    _logger.info('FCM token updated');
  }

  Future<void> _handleForegroundMessage(
    RemoteMessage message,
    String userId,
  ) async {
    final notification = message.notification;
    if (notification == null) return;

    final repository = _notificationsRepository;
    AppNotification? inboxNotification;

    if (repository != null) {
      final type = NotificationType.fromString(
        message.data['type'] as String?,
      );
      final dedupeKey =
          message.data['dedupe_key'] as String? ?? message.messageId ?? '';

      final exists = dedupeKey.isNotEmpty
          ? await repository.existsByDedupeKey(
              userId: userId,
              dedupeKey: dedupeKey,
            )
          : false;

      if (!exists) {
        inboxNotification = await repository.createNotification(
          userId: userId,
          params: CreateNotificationParams(
            type: type,
            title: notification.title ?? 'Notification',
            body: notification.body ?? '',
            entityId: message.data['entity_id'] as String?,
            entityType: message.data['entity_type'] as String?,
            routePath: message.data['route_path'] as String?,
            scheduledAt: DateTime.now(),
            dedupeKey: dedupeKey.isNotEmpty
                ? dedupeKey
                : 'fcm_${DateTime.now().microsecondsSinceEpoch}',
          ),
        );
      }
    }

    await _localNotificationService.showNotification(
      inboxNotification ??
          AppNotification(
            id: message.messageId ?? 'fcm-${DateTime.now().microsecondsSinceEpoch}',
            userId: userId,
            type: NotificationType.fromString(message.data['type'] as String?),
            title: notification.title ?? 'Notification',
            body: notification.body ?? '',
            entityId: message.data['entity_id'] as String?,
            entityType: message.data['entity_type'] as String?,
            routePath: message.data['route_path'] as String?,
            isRead: false,
            createdAt: DateTime.now(),
            scheduledAt: DateTime.now(),
            dedupeKey: message.messageId ?? '',
          ),
    );
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
