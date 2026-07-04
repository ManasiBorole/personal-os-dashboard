import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/app.dart';
import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';
import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';

void main() {
  const appConfig = AppConfig(
    environment: AppEnvironment.dev,
    supabaseUrl: '',
    supabaseAnonKey: '',
  );

  setUp(() async {
    final hivePath = Directory.systemTemp.createTempSync('personal_os_test').path;
    await configureDependencies(appConfig, hivePath: hivePath);
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets('redirects unauthenticated users to login', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(appConfig),
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUnauthenticated()),
          ),
        ],
        child: const PersonalOsApp(appConfig: appConfig),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('shows dashboard shell for authenticated users', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(appConfig),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AuthAuthenticated(
                AuthUser(id: 'user-1', email: 'user@example.com'),
              ),
            ),
          ),
        ],
        child: const PersonalOsApp(appConfig: appConfig),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Task Summary'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
