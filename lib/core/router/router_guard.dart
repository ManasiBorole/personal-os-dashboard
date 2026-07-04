import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';

/// Resolves navigation redirects based on authentication state.
abstract final class RouterGuard {
  static String? resolve({
    required Ref ref,
    required GoRouterState state,
  }) {
    final authAsync = ref.read(authStateProvider);
    return resolveFromAsync(authAsync, state.matchedLocation);
  }

  static String? resolveFromAsync(
    AsyncValue<AuthState> authAsync,
    String location,
  ) {
    return authAsync.when(
      loading: () => _handleLoading(location),
      error: (_, _) => _handleUnauthenticated(location),
      data: (authState) => _handleAuthState(
        location: location,
        authState: authState,
      ),
    );
  }

  static String? _handleLoading(String location) {
    if (location == RouteConstants.splash) {
      return null;
    }

    return RouteConstants.splash;
  }

  static String? _handleUnauthenticated(String location) {
    if (RouteConstants.isPublicRoute(location)) {
      return location == RouteConstants.splash ? RouteConstants.login : null;
    }

    return RouteConstants.login;
  }

  static String? _handleAuthState({
    required String location,
    required AuthState authState,
  }) {
    final isAuthenticated = authState.isAuthenticated;

    if (location == RouteConstants.splash) {
      return isAuthenticated
          ? RouteConstants.dashboard
          : RouteConstants.login;
    }

    if (!isAuthenticated) {
      if (RouteConstants.isPublicRoute(location)) {
        return null;
      }

      return RouteConstants.login;
    }

    if (location == RouteConstants.login || location == RouteConstants.signup) {
      return RouteConstants.dashboard;
    }

    return null;
  }
}
