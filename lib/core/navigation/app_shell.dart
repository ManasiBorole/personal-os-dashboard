import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/navigation/navigation_destinations.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';

/// Authenticated application shell with adaptive navigation.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final isCompactHeight = MediaQuery.sizeOf(context).height < 700;

    if ((isDesktop || isTablet) && !isCompactHeight) {
      return _DesktopShell(location: location, child: child);
    }

    return _MobileShell(location: location, child: child);
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Material(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(height: 1),
                  for (final item in NavigationDestinations.all)
                    ListTile(
                      leading: Icon(
                        location == item.path ? item.selectedIcon : item.icon,
                      ),
                      title: Text(item.label),
                      selected: location == item.path,
                      onTap: () => _onDestinationSelected(context, item),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primaryDestinations = NavigationDestinations.primary;
    final selectedIndex = primaryDestinations.indexWhere(
      (item) => item.path == location,
    );

    return Scaffold(
      drawer: _AppDrawer(location: location),
      appBar: AppBar(
        title: Text(
          NavigationDestinations.fromPath(location)?.label ?? AppConstants.appName,
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(RouteConstants.profile),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(
          context,
          primaryDestinations[index],
        ),
        destinations: [
          for (final item in primaryDestinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  for (final item in NavigationDestinations.all)
                    ListTile(
                      leading: Icon(
                        location == item.path ? item.selectedIcon : item.icon,
                      ),
                      title: Text(item.label),
                      selected: location == item.path,
                      onTap: () {
                        Navigator.of(context).pop();
                        _onDestinationSelected(context, item);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _onDestinationSelected(
  BuildContext context,
  NavigationDestinationItem item,
) {
  context.go(item.path);
}
