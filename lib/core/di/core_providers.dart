import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/network/network_helper.dart';
import 'package:personal_os_dashboard/core/network/network_info.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/core/supabase/domain/repositories/file_storage_repository.dart';
import 'package:personal_os_dashboard/core/supabase/services/auth_service.dart';
import 'package:personal_os_dashboard/core/supabase/services/database_service.dart';
import 'package:personal_os_dashboard/core/supabase/services/storage_service.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_service.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_os_dashboard/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';

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

/// Local storage helper provider.
final storageHelperProvider = Provider<StorageHelper>((ref) {
  return sl<StorageHelper>();
});

/// Supabase service provider.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return sl<SupabaseService>();
});

/// Supabase auth service provider.
final authServiceProvider = Provider<AuthService>((ref) {
  return sl<AuthService>();
});

/// Supabase database service provider.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return sl<DatabaseService>();
});

/// Supabase storage service provider.
final storageServiceProvider = Provider<StorageService>((ref) {
  return sl<StorageService>();
});

/// Authentication repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return sl<AuthRepository>();
});

/// File storage repository provider.
final fileStorageRepositoryProvider = Provider<FileStorageRepository>((ref) {
  return sl<FileStorageRepository>();
});

/// Dashboard remote data source provider.
final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return sl<DashboardRemoteDataSource>();
});

/// Dashboard repository provider.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return sl<DashboardRepository>();
});
