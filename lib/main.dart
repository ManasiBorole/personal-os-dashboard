import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/app.dart';
import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/supabase_bootstrap.dart';
import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  final appConfig = AppConfig.fromEnv();

  await configureDependencies(appConfig);

  await initializeSupabase(
    config: appConfig,
    logger: sl(),
  );

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
}
