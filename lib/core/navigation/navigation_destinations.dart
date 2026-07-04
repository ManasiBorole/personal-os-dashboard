import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/router/route_paths.dart';

/// Navigation destination metadata for the application shell.
final class NavigationDestinationItem {
  const NavigationDestinationItem({
    required this.path,
    required this.name,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.isPrimary = false,
  });

  final String path;
  final String name;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isPrimary;
}

/// All navigable destinations in the authenticated shell.
abstract final class NavigationDestinations {
  static const List<NavigationDestinationItem> all = [
    NavigationDestinationItem(
      path: RouteConstants.dashboard,
      name: RoutePaths.dashboard,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      isPrimary: true,
    ),
    NavigationDestinationItem(
      path: RouteConstants.goals,
      name: RoutePaths.goals,
      label: 'Goals',
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
    ),
    NavigationDestinationItem(
      path: RouteConstants.projects,
      name: RoutePaths.projects,
      label: 'Projects',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
    ),
    NavigationDestinationItem(
      path: RouteConstants.tasks,
      name: RoutePaths.tasks,
      label: 'Tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
      isPrimary: true,
    ),
    NavigationDestinationItem(
      path: RouteConstants.calendar,
      name: RoutePaths.calendar,
      label: 'Calendar',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      isPrimary: true,
    ),
    NavigationDestinationItem(
      path: RouteConstants.meetings,
      name: RoutePaths.meetings,
      label: 'Meetings',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
    ),
    NavigationDestinationItem(
      path: RouteConstants.crm,
      name: RoutePaths.crm,
      label: 'CRM',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    NavigationDestinationItem(
      path: RouteConstants.notes,
      name: RoutePaths.notes,
      label: 'Notes',
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt,
    ),
    NavigationDestinationItem(
      path: RouteConstants.documents,
      name: RoutePaths.documents,
      label: 'Documents',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
    ),
    NavigationDestinationItem(
      path: RouteConstants.analytics,
      name: RoutePaths.analytics,
      label: 'Analytics',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
    ),
    NavigationDestinationItem(
      path: RouteConstants.notifications,
      name: RoutePaths.notifications,
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      isPrimary: true,
    ),
    NavigationDestinationItem(
      path: RouteConstants.settings,
      name: RoutePaths.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      isPrimary: true,
    ),
    NavigationDestinationItem(
      path: RouteConstants.profile,
      name: RoutePaths.profile,
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  static List<NavigationDestinationItem> get primary =>
      all.where((item) => item.isPrimary).toList();

  static NavigationDestinationItem? fromPath(String path) {
    for (final item in all) {
      if (item.path == path) {
        return item;
      }
    }

    return null;
  }
}
