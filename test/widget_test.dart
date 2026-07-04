import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/app.dart';
import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';
import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';

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

  testWidgets('renders application bootstrap shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(appConfig),
        ],
        child: const PersonalOsApp(appConfig: appConfig),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Enterprise foundation initialized'), findsOneWidget);
  });
}
