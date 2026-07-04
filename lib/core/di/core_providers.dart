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
import 'package:personal_os_dashboard/features/goals/data/datasources/goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/domain/repositories/goals_repository.dart';
import 'package:personal_os_dashboard/features/projects/data/datasources/projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/domain/repositories/projects_repository.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:personal_os_dashboard/features/calendar/data/datasources/calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:personal_os_dashboard/features/meetings/data/datasources/meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:personal_os_dashboard/features/crm/data/datasources/crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/domain/repositories/crm_repository.dart';
import 'package:personal_os_dashboard/features/notes/data/datasources/notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/domain/repositories/notes_repository.dart';
import 'package:personal_os_dashboard/features/documents/data/datasources/documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/domain/repositories/documents_repository.dart';
import 'package:personal_os_dashboard/features/analytics/domain/repositories/analytics_repository.dart';

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

/// Goals data source provider.
final goalsDataSourceProvider = Provider<GoalsDataSource>((ref) {
  return sl<GoalsDataSource>();
});

/// Goals repository provider.
final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return sl<GoalsRepository>();
});

/// Projects data source provider.
final projectsDataSourceProvider = Provider<ProjectsDataSource>((ref) {
  return sl<ProjectsDataSource>();
});

/// Projects repository provider.
final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return sl<ProjectsRepository>();
});

/// Tasks data source provider.
final tasksDataSourceProvider = Provider<TasksDataSource>((ref) {
  return sl<TasksDataSource>();
});

/// Tasks repository provider.
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return sl<TasksRepository>();
});

/// Calendar data source provider.
final calendarDataSourceProvider = Provider<CalendarDataSource>((ref) {
  return sl<CalendarDataSource>();
});

/// Calendar repository provider.
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return sl<CalendarRepository>();
});

/// Meetings data source provider.
final meetingsDataSourceProvider = Provider<MeetingsDataSource>((ref) {
  return sl<MeetingsDataSource>();
});

/// Meetings repository provider.
final meetingsRepositoryProvider = Provider<MeetingsRepository>((ref) {
  return sl<MeetingsRepository>();
});

/// CRM data source provider.
final crmDataSourceProvider = Provider<CrmDataSource>((ref) {
  return sl<CrmDataSource>();
});

/// CRM repository provider.
final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  return sl<CrmRepository>();
});

/// Notes data source provider.
final notesDataSourceProvider = Provider<NotesDataSource>((ref) {
  return sl<NotesDataSource>();
});

/// Notes repository provider.
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return sl<NotesRepository>();
});

/// Documents data source provider.
final documentsDataSourceProvider = Provider<DocumentsDataSource>((ref) {
  return sl<DocumentsDataSource>();
});

/// Documents repository provider.
final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return sl<DocumentsRepository>();
});

/// Analytics repository provider.
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return sl<AnalyticsRepository>();
});
