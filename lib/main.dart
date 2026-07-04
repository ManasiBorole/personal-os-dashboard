import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/app.dart';
import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/env_bootstrap.dart';
import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/notifications/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    final bootstrapResult = await EnvBootstrap.load();

    final appConfig = AppConfig.fromEnv();

    await configureDependencies(appConfig);

    EnvBootstrap.logStartupConfig(
      appConfig,
      bootstrap: bootstrapResult,
      logger: sl<AppLogger>(),
    );

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    FlutterError.onError = (details) {
      sl<ErrorHandler>().handle(
        details.exception,
        stackTrace: details.stack,
        context: 'FlutterError',
      );
    };

    runApp(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(appConfig),
        ],
        child: PersonalOsApp(appConfig: appConfig),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('[Startup] Uncaught error: $error');
    debugPrint(stackTrace.toString());
    if (sl.isRegistered<ErrorHandler>()) {
      sl<ErrorHandler>().handle(
        error,
        stackTrace: stackTrace,
        context: 'Zone',
      );
    }
  });
}
