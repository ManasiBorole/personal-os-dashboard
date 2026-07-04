import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/network/connectivity_service.dart';
import 'package:personal_os_dashboard/core/network/network_info.dart';

/// Global application configuration provider.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden at startup.');
});

/// Application logger instance.
final loggerProvider = Provider<Logger>((ref) {
  final config = ref.watch(appConfigProvider);

  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: config.environment.isProd ? Level.warning : Level.debug,
  );
});

/// Network connectivity service provider.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return ConnectivityService();
});
