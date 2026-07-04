import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/router/route_paths.dart';
import 'package:personal_os_dashboard/core/widgets/layout/app_bootstrap.dart';

/// Root navigator key for imperative navigation.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider.
///
/// Feature modules will register their routes here as they are implemented.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RoutePaths.splash,
        builder: (context, state) => const AppBootstrap(),
      ),
    ],
  );
});
