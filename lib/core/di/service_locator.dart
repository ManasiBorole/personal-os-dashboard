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
import 'package:personal_os_dashboard/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:personal_os_dashboard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:personal_os_dashboard/features/goals/data/datasources/goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/datasources/supabase_goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:personal_os_dashboard/features/goals/domain/repositories/goals_repository.dart';
import 'package:personal_os_dashboard/features/projects/data/datasources/projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/data/datasources/supabase_projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:personal_os_dashboard/features/projects/domain/repositories/projects_repository.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/supabase_tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:personal_os_dashboard/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:personal_os_dashboard/features/calendar/data/datasources/calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/datasources/supabase_calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:personal_os_dashboard/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:personal_os_dashboard/features/meetings/data/datasources/meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/datasources/supabase_meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:personal_os_dashboard/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:personal_os_dashboard/features/crm/data/datasources/crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/datasources/supabase_crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/repositories/crm_repository_impl.dart';
import 'package:personal_os_dashboard/features/crm/data/services/visiting_card_storage.dart';
import 'package:personal_os_dashboard/features/crm/domain/repositories/crm_repository.dart';
import 'package:personal_os_dashboard/features/notes/data/datasources/notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/datasources/supabase_notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:personal_os_dashboard/features/notes/data/services/note_attachment_storage.dart';
import 'package:personal_os_dashboard/features/notes/domain/repositories/notes_repository.dart';
import 'package:personal_os_dashboard/features/documents/data/datasources/documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/datasources/supabase_documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:personal_os_dashboard/features/documents/data/services/document_storage_service.dart';
import 'package:personal_os_dashboard/features/documents/domain/repositories/documents_repository.dart';
import 'package:personal_os_dashboard/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:personal_os_dashboard/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:personal_os_dashboard/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/data/datasources/supabase_notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:personal_os_dashboard/features/notifications/data/services/notification_coordinator.dart';
import 'package:personal_os_dashboard/features/notifications/data/services/reminder_scheduler_service.dart';
import 'package:personal_os_dashboard/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:personal_os_dashboard/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:personal_os_dashboard/features/settings/domain/repositories/settings_repository.dart';
import 'package:personal_os_dashboard/core/notifications/fcm_service.dart';
import 'package:personal_os_dashboard/core/notifications/local_notification_service.dart';

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
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => SupabaseDashboardRemoteDataSource(sl<DatabaseService>()),
  );
  sl.registerLazySingleton<GoalsDataSource>(
    () => SupabaseGoalsDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<ProjectsDataSource>(
    () => SupabaseProjectsDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<TasksDataSource>(
    () => SupabaseTasksDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<CalendarDataSource>(
    () => SupabaseCalendarDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<MeetingsDataSource>(
    () => SupabaseMeetingsDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<CrmDataSource>(
    () => SupabaseCrmDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<NotesDataSource>(
    () => SupabaseNotesDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<DocumentsDataSource>(
    () => SupabaseDocumentsDataSource(sl<DatabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<NotificationsDataSource>(
    () => SupabaseNotificationsDataSource(sl<DatabaseRemoteDataSource>()),
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
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
  );
  sl.registerLazySingleton<GoalsRepository>(
    () => createGoalsRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<GoalsDataSource>(),
    ),
  );
  sl.registerLazySingleton<ProjectsRepository>(
    () => createProjectsRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<ProjectsDataSource>(),
    ),
  );
  sl.registerLazySingleton<TasksRepository>(
    () => createTasksRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<TasksDataSource>(),
    ),
  );
  sl.registerLazySingleton<CalendarRepository>(
    () => createCalendarRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<CalendarDataSource>(),
      tasksDataSource: sl<TasksDataSource>(),
    ),
  );
  sl.registerLazySingleton<MeetingsRepository>(
    () => createMeetingsRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<MeetingsDataSource>(),
    ),
  );
  sl.registerLazySingleton<CrmRepository>(
    () => createCrmRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<CrmDataSource>(),
      visitingCardStorage: VisitingCardStorage(sl<FileStorageRepository>()),
    ),
  );
  sl.registerLazySingleton<NotesRepository>(
    () => createNotesRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<NotesDataSource>(),
      attachmentStorage: NoteAttachmentStorage(sl<FileStorageRepository>()),
    ),
  );
  sl.registerLazySingleton<DocumentsRepository>(
    () => createDocumentsRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<DocumentsDataSource>(),
      storageService: DocumentStorageService(sl<FileStorageRepository>()),
    ),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => createAnalyticsRepository(
      tasksRepository: sl<TasksRepository>(),
      goalsRepository: sl<GoalsRepository>(),
      projectsRepository: sl<ProjectsRepository>(),
      meetingsRepository: sl<MeetingsRepository>(),
    ),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => createNotificationsRepository(
      isSupabaseReady: sl<SupabaseService>().isInitialized,
      remoteDataSource: sl<NotificationsDataSource>(),
    ),
  );

  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(sl<AppLogger>()),
  );
  sl.registerLazySingleton<FcmService>(
    () => FcmService(
      logger: sl<AppLogger>(),
      storageHelper: sl<StorageHelper>(),
      localNotificationService: sl<LocalNotificationService>(),
      notificationsRepository: sl<NotificationsRepository>(),
    ),
  );
  sl.registerLazySingleton<ReminderSchedulerService>(
    () => ReminderSchedulerService(
      tasksRepository: sl<TasksRepository>(),
      meetingsRepository: sl<MeetingsRepository>(),
      goalsRepository: sl<GoalsRepository>(),
      crmRepository: sl<CrmRepository>(),
      calendarRepository: sl<CalendarRepository>(),
      notificationsRepository: sl<NotificationsRepository>(),
    ),
  );
  sl.registerLazySingleton<NotificationCoordinator>(
    () => NotificationCoordinator(
      fcmService: sl<FcmService>(),
      localNotificationService: sl<LocalNotificationService>(),
      reminderScheduler: sl<ReminderSchedulerService>(),
    ),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => createSettingsRepository(storageHelper: sl<StorageHelper>()),
  );

  sl<AppLogger>().info(
    'Core dependencies configured [${config.environment.name}]',
  );
}

/// Resets all registered dependencies. For testing only.
Future<void> resetDependencies() async {
  await sl.reset();
}
