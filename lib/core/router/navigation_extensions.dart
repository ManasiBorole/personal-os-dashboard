import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/router/route_paths.dart';

/// Type-safe navigation helpers for GoRouter.
extension AppNavigation on GoRouter {
  void goSplash() => go(RouteConstants.splash);

  void goLogin() => go(RouteConstants.login);

  void goSignup() => go(RouteConstants.signup);

  void goDashboard() => go(RouteConstants.dashboard);

  void goGoals() => go(RouteConstants.goals);

  void goProjects() => go(RouteConstants.projects);

  void goTasks() => go(RouteConstants.tasks);

  void goCalendar() => go(RouteConstants.calendar);

  void goMeetings() => go(RouteConstants.meetings);

  void goCrm() => go(RouteConstants.crm);

  void goNotes() => go(RouteConstants.notes);

  void goDocuments() => go(RouteConstants.documents);

  void goAnalytics() => go(RouteConstants.analytics);

  void goNotifications() => go(RouteConstants.notifications);

  void goSettings() => go(RouteConstants.settings);

  void goProfile() => go(RouteConstants.profile);
}

extension AppNamedNavigation on BuildContext {
  void goNamedDashboard() => goNamed(RoutePaths.dashboard);

  void goNamedLogin() => goNamed(RoutePaths.login);

  void goNamedSignup() => goNamed(RoutePaths.signup);

  void goNamedProfile() => goNamed(RoutePaths.profile);
}
