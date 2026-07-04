import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/features/auth/data/constants/local_dev_auth_config.dart';
import 'package:personal_os_dashboard/features/auth/data/repositories/local_dev_auth_repository.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

void main() {
  late Directory tempDir;
  late StorageHelper storage;
  late LocalDevAuthRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('local_auth_test');
    const config = AppConfig(
      environment: AppEnvironment.dev,
      supabaseUrl: '',
      supabaseAnonKey: '',
    );
    storage = StorageHelper(AppLogger(config));
    await storage.init(path: tempDir.path);
    repository = LocalDevAuthRepository(storage);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('signs in with seeded test credentials and emits authenticated state',
      () async {
    final states = <AuthState>[];
    final subscription = repository.watchAuthState().listen(states.add);

    await repository.signIn(
      email: LocalDevAuthConfig.defaultTestEmail,
      password: LocalDevAuthConfig.defaultTestPassword,
    );

    await Future<void>.delayed(Duration.zero);

    expect(repository.currentAuthState.isAuthenticated, isTrue);
    expect(states.last, isA<AuthAuthenticated>());

    await subscription.cancel();
  });

  test('signs up new user then signs in', () async {
    await repository.signUp(
      email: 'dev.user@example.com',
      password: 'password123',
    );

    await repository.signIn(
      email: 'dev.user@example.com',
      password: 'password123',
    );

    expect(repository.currentAuthState.isAuthenticated, isTrue);
  });

  test('rejects invalid credentials', () async {
    await expectLater(
      repository.signIn(
        email: LocalDevAuthConfig.defaultTestEmail,
        password: 'wrong-password',
      ),
      throwsA(isA<Exception>()),
    );
  });
}
