import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/router/router_guard.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

void main() {
  group('RouterGuard', () {
    test('redirects unauthenticated users to login', () {
      final redirect = RouterGuard.resolveFromAsync(
        const AsyncData(AuthUnauthenticated()),
        RouteConstants.dashboard,
      );

      expect(redirect, RouteConstants.login);
    });

    test('redirects authenticated users away from login', () {
      final redirect = RouterGuard.resolveFromAsync(
        const AsyncData(
          AuthAuthenticated(
            AuthUser(id: 'user-1', email: 'user@example.com'),
          ),
        ),
        RouteConstants.login,
      );

      expect(redirect, RouteConstants.dashboard);
    });

    test('allows authenticated access to protected routes', () {
      final redirect = RouterGuard.resolveFromAsync(
        const AsyncData(
          AuthAuthenticated(
            AuthUser(id: 'user-1', email: 'user@example.com'),
          ),
        ),
        RouteConstants.tasks,
      );

      expect(redirect, isNull);
    });

    test('redirects authenticated users away from forgot password', () {
      final redirect = RouterGuard.resolveFromAsync(
        const AsyncData(
          AuthAuthenticated(
            AuthUser(id: 'user-1', email: 'user@example.com'),
          ),
        ),
        RouteConstants.forgotPassword,
      );

      expect(redirect, RouteConstants.dashboard);
    });

    test('allows unauthenticated access to forgot password', () {
      final redirect = RouterGuard.resolveFromAsync(
        const AsyncData(AuthUnauthenticated()),
        RouteConstants.forgotPassword,
      );

      expect(redirect, isNull);
    });

    test('sends loading users to splash', () {
      final redirect = RouterGuard.resolveFromAsync(
        const AsyncLoading<AuthState>(),
        RouteConstants.dashboard,
      );

      expect(redirect, RouteConstants.splash);
    });
  });
}
