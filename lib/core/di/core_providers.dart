import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/network/connectivity_service.dart';
import 'package:personal_os_dashboard/core/network/network_helper.dart';
import 'package:personal_os_dashboard/core/network/network_info.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';

/// Global application configuration provider.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden at startup.');
});

/// Application logger provider.
final appLoggerProvider = Provider<AppLogger>((ref) {
  return sl<AppLogger>();
});

/// Error handler provider.
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return sl<ErrorHandler>();
});

/// Network connectivity provider.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return sl<NetworkInfo>();
});

/// Network helper provider.
final networkHelperProvider = Provider<NetworkHelper>((ref) {
  return sl<NetworkHelper>();
});

/// Storage helper provider.
final storageHelperProvider = Provider<StorageHelper>((ref) {
  return sl<StorageHelper>();
});

/// Fallback registration when service locator is not yet configured.
void registerFallbackProviders() {
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(ConnectivityService.new);
  }
}
