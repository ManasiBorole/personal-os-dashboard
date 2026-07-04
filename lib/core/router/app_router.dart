import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/navigation/app_shell.dart';
import 'package:personal_os_dashboard/core/navigation/feature_placeholder_screen.dart';
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
      _placeholderRoute(
        path: RouteConstants.projects,
        name: RoutePaths.projects,
        title: 'Projects',
        description: 'Organize work into focused initiatives.',
        icon: Icons.folder_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.tasks,
        name: RoutePaths.tasks,
        title: 'Tasks',
        description: 'Manage daily actions and priorities.',
        icon: Icons.task_alt_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.calendar,
        name: RoutePaths.calendar,
        title: 'Calendar',
        description: 'View and schedule your time.',
        icon: Icons.calendar_month_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.meetings,
        name: RoutePaths.meetings,
        title: 'Meetings',
        description: 'Plan meetings, agendas, and attendees.',
        icon: Icons.groups_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.crm,
        name: RoutePaths.crm,
        title: 'CRM',
        description: 'Manage contacts, companies, and interactions.',
        icon: Icons.people_outline,
      ),
      _placeholderRoute(
        path: RouteConstants.notes,
        name: RoutePaths.notes,
        title: 'Notes',
        description: 'Capture ideas and knowledge.',
        icon: Icons.note_alt_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.documents,
        name: RoutePaths.documents,
        title: 'Documents',
        description: 'Store and organize files.',
        icon: Icons.description_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.analytics,
        name: RoutePaths.analytics,
        title: 'Analytics',
        description: 'Review productivity insights and trends.',
        icon: Icons.analytics_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.notifications,
        name: RoutePaths.notifications,
        title: 'Notifications',
        description: 'Stay updated on important activity.',
        icon: Icons.notifications_outlined,
      ),
      _placeholderRoute(
        path: RouteConstants.settings,
        name: RoutePaths.settings,
        title: 'Settings',
        description: 'Configure your account and preferences.',
        icon: Icons.settings_outlined,
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: RoutePaths.profile,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfileScreen(),
        ),
      ),
    ];

GoRoute _placeholderRoute({
  required String path,
  required String name,
  required String title,
  required String description,
  required IconData icon,
}) {
  return GoRoute(
    path: path,
    name: name,
    pageBuilder: (context, state) => NoTransitionPage(
      child: FeaturePlaceholderScreen(
        title: title,
        description: description,
        icon: icon,
      ),
    ),
  );
}
