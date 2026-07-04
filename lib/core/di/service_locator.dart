import 'package:get_it/get_it.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/network/connectivity_service.dart';
import 'package:personal_os_dashboard/core/network/network_helper.dart';
import 'package:personal_os_dashboard/core/network/network_info.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/core/supabase/data/repositories/file_storage_repository_impl.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/auth_remote_datasource.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/core/supabase/domain/repositories/file_storage_repository.dart';
import 'package:personal_os_dashboard/core/supabase/services/auth_service.dart';
import 'package:personal_os_dashboard/core/supabase/services/database_service.dart';
import 'package:personal_os_dashboard/core/supabase/services/storage_service.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_service.dart';
import 'package:personal_os_dashboard/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

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

  // Local storage
  sl.registerLazySingleton<StorageHelper>(
    () => StorageHelper(sl<AppLogger>()),
  );

  final storageHelper = sl<StorageHelper>();
  await storageHelper.init(path: hivePath);

  // Supabase
  sl.registerLazySingleton<SupabaseService>(
    () => SupabaseService(
      config: sl<AppConfig>(),
      logger: sl<AppLogger>(),
    ),
  );

  await sl<SupabaseService>().initialize();

  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<DatabaseService>(
    () => DatabaseService(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<StorageService>(
    () => StorageService(sl<SupabaseService>()),
  );

  // Supabase data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthRemoteDataSource(sl<AuthService>()),
  );
  sl.registerLazySingleton<DatabaseRemoteDataSource>(
    () => SupabaseDatabaseRemoteDataSource(sl<DatabaseService>()),
  );
  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => SupabaseStorageRemoteDataSource(sl<StorageService>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => createAuthRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<FileStorageRepository>(
    () => FileStorageRepositoryImpl(sl<StorageRemoteDataSource>()),
  );

  sl<AppLogger>().info(
    'Core dependencies configured [${config.environment.name}]',
  );
}

/// Resets all registered dependencies. For testing only.
Future<void> resetDependencies() async {
  await sl.reset();
}
