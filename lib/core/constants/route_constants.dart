/// GoRouter path constants.
abstract final class RouteConstants {
  // Public routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Protected routes
  static const String dashboard = '/dashboard';
  static const String goals = '/goals';
  static const String goalCreate = '/goals/new';
  static const String goalEdit = '/goals/:id/edit';
  static const String projects = '/projects';
  static const String projectCreate = '/projects/new';
  static const String projectDetail = '/projects/:id';
  static const String projectEdit = '/projects/:id/edit';
  static const String tasks = '/tasks';
  static const String taskCreate = '/tasks/new';
  static const String taskEdit = '/tasks/:id/edit';
  static const String calendar = '/calendar';
  static const String calendarCreate = '/calendar/new';
  static const String calendarEdit = '/calendar/:id/edit';
  static const String meetings = '/meetings';
  static const String crm = '/crm';
  static const String notes = '/notes';
  static const String documents = '/documents';
  static const String analytics = '/analytics';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Routes accessible without authentication.
  static const Set<String> publicRoutes = {
    splash,
    login,
    signup,
    forgotPassword,
  };

  /// Routes that require an authenticated session.
  static const Set<String> protectedRoutes = {
    dashboard,
    goals,
    projects,
    tasks,
    calendar,
    meetings,
    crm,
    notes,
    documents,
    analytics,
    notifications,
    settings,
    profile,
  };

  static bool isPublicRoute(String location) => publicRoutes.contains(location);

  static bool isProtectedRoute(String location) =>
      protectedRoutes.contains(location);
}
