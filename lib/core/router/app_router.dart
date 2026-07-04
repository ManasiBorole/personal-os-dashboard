import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/navigation/app_shell.dart';
import 'package:personal_os_dashboard/core/router/go_router_refresh_notifier.dart';
import 'package:personal_os_dashboard/core/router/route_paths.dart';
import 'package:personal_os_dashboard/core/router/router_guard.dart';
import 'package:personal_os_dashboard/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:personal_os_dashboard/features/auth/presentation/screens/login_screen.dart';
import 'package:personal_os_dashboard/features/auth/presentation/screens/signup_screen.dart';
import 'package:personal_os_dashboard/features/auth/presentation/screens/splash_screen.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:personal_os_dashboard/features/goals/presentation/screens/goal_form_screen.dart';
import 'package:personal_os_dashboard/features/goals/presentation/screens/goals_screen.dart';
import 'package:personal_os_dashboard/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:personal_os_dashboard/features/projects/presentation/screens/project_form_screen.dart';
import 'package:personal_os_dashboard/features/projects/presentation/screens/projects_screen.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/screens/calendar_event_form_screen.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:personal_os_dashboard/features/crm/presentation/screens/company_form_screen.dart';
import 'package:personal_os_dashboard/features/crm/presentation/screens/contact_detail_screen.dart';
import 'package:personal_os_dashboard/features/crm/presentation/screens/contact_form_screen.dart';
import 'package:personal_os_dashboard/features/crm/presentation/screens/crm_screen.dart';
import 'package:personal_os_dashboard/features/notes/presentation/screens/note_form_screen.dart';
import 'package:personal_os_dashboard/features/notes/presentation/screens/notes_screen.dart';
import 'package:personal_os_dashboard/features/documents/presentation/screens/document_preview_screen.dart';
import 'package:personal_os_dashboard/features/documents/presentation/screens/documents_screen.dart';
import 'package:personal_os_dashboard/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:personal_os_dashboard/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/backup_settings_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/security_settings_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/settings_screen.dart';
import 'package:personal_os_dashboard/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:personal_os_dashboard/features/profile/presentation/screens/profile_screen.dart';

/// Root navigator key for imperative navigation.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shell navigator key for authenticated routes.
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration with authentication route protection.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(goRouterRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => RouterGuard.resolve(ref: ref, state: state),
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signup,
        name: RoutePaths.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: _protectedRoutes,
      ),
    ],
  );
});

List<GoRoute> get _protectedRoutes => [
      GoRoute(
        path: RouteConstants.dashboard,
        name: RoutePaths.dashboard,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.goals,
        name: RoutePaths.goals,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: GoalsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: RoutePaths.goalCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const GoalFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: RoutePaths.goalEdit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => GoalFormScreen(
              goalId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.projects,
        name: RoutePaths.projects,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProjectsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: RoutePaths.projectCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ProjectFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: RoutePaths.projectDetail,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => ProjectDetailScreen(
              projectId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: RoutePaths.projectEdit,
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => ProjectFormScreen(
                  projectId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.tasks,
        name: RoutePaths.tasks,
        pageBuilder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'];
          return NoTransitionPage(
            child: TasksScreen(initialProjectId: projectId),
          );
        },
        routes: [
          GoRoute(
            path: 'new',
            name: RoutePaths.taskCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => TaskFormScreen(
              initialProjectId: state.uri.queryParameters['projectId'],
            ),
          ),
          GoRoute(
            path: ':id/edit',
            name: RoutePaths.taskEdit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => TaskFormScreen(
              taskId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.calendar,
        name: RoutePaths.calendar,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CalendarScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: RoutePaths.calendarCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final dayParam = state.uri.queryParameters['day'];
              final initialDay =
                  dayParam != null ? DateTime.tryParse(dayParam) : null;
              return CalendarEventFormScreen(initialDay: initialDay);
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: RoutePaths.calendarEdit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => CalendarEventFormScreen(
              eventId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.meetings,
        name: RoutePaths.meetings,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MeetingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: RoutePaths.meetingCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const MeetingFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: RoutePaths.meetingDetail,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => MeetingDetailScreen(
              meetingId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: RoutePaths.meetingEdit,
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => MeetingFormScreen(
                  meetingId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.crm,
        name: RoutePaths.crm,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CrmScreen(),
        ),
        routes: [
          GoRoute(
            path: 'contacts/new',
            name: RoutePaths.contactCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ContactFormScreen(),
          ),
          GoRoute(
            path: 'contacts/:id',
            name: RoutePaths.contactDetail,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => ContactDetailScreen(
              contactId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: RoutePaths.contactEdit,
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => ContactFormScreen(
                  contactId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'companies/new',
            name: RoutePaths.companyCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const CompanyFormScreen(),
          ),
          GoRoute(
            path: 'companies/:id/edit',
            name: RoutePaths.companyEdit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => CompanyFormScreen(
              companyId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.notes,
        name: RoutePaths.notes,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: NotesScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: RoutePaths.noteCreate,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const NoteFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: RoutePaths.noteEdit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => NoteFormScreen(
              noteId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.documents,
        name: RoutePaths.documents,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DocumentsScreen(),
        ),
        routes: [
          GoRoute(
            path: ':id/preview',
            name: RoutePaths.documentPreview,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => DocumentPreviewScreen(
              documentId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.analytics,
        name: RoutePaths.analytics,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.notifications,
        name: RoutePaths.notifications,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.settings,
        name: RoutePaths.settings,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SettingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'profile/edit',
            name: RoutePaths.settingsEditProfile,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'theme',
            name: RoutePaths.settingsTheme,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'security',
            name: RoutePaths.settingsSecurity,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          GoRoute(
            path: 'backup',
            name: RoutePaths.settingsBackup,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const BackupSettingsScreen(),
          ),
          GoRoute(
            path: 'language',
            name: RoutePaths.settingsLanguage,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const LanguageSettingsScreen(),
          ),
          GoRoute(
            path: 'notification-preferences',
            name: RoutePaths.settingsNotificationPrefs,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'privacy',
            name: RoutePaths.settingsPrivacy,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const PrivacySettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: RoutePaths.profile,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfileScreen(),
        ),
      ),
    ];
