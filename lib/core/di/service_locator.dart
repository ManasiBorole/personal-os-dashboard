import 'package:get_it/get_it.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/network/connectivity_service.dart';
import 'package:personal_os_dashboard/core/network/network_helper.dart';
import 'package:personal_os_dashboard/core/network/network_info.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Registers all core system dependencies.
Future<void> configureDependencies(
  AppConfig config, {
  String? hivePath,
}) async {
  if (sl.isRegistered<AppConfig>()) {
    return;
  }

  // Config
  sl.registerSingleton<AppConfig>(config);

  // Logging
  sl.registerLazySingleton<AppLogger>(() => AppLogger(sl<AppConfig>()));

  // Error handling
  sl.registerLazySingleton<ErrorHandler>(
    () => ErrorHandler(sl<AppLogger>()),
  );

  // Network
  sl.registerLazySingleton<NetworkInfo>(ConnectivityService.new);
  sl.registerLazySingleton<NetworkHelper>(
    () => NetworkHelper(
      config: sl<AppConfig>(),
      logger: sl<AppLogger>(),
      errorHandler: sl<ErrorHandler>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Storage
  sl.registerLazySingleton<StorageHelper>(
    () => StorageHelper(sl<AppLogger>()),
  );

  final storageHelper = sl<StorageHelper>();
  await storageHelper.init(path: hivePath);

  sl<AppLogger>().info(
    'Core dependencies configured [${config.environment.name}]',
  );
}

/// Resets all registered dependencies. For testing only.
Future<void> resetDependencies() async {
  await sl.reset();
}
