import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/auth_remote_datasource.dart';
import 'package:personal_os_dashboard/core/supabase/services/auth_service.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_exception.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_service.dart';
import 'package:personal_os_dashboard/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:personal_os_dashboard/features/auth/data/repositories/local_dev_auth_repository.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

void main() {
  const unconfiguredConfig = AppConfig(
    environment: AppEnvironment.prod,
    supabaseUrl: '',
    supabaseAnonKey: '',
    developmentMode: false,
  );

  const developmentConfig = AppConfig(
    environment: AppEnvironment.dev,
    supabaseUrl: '',
    supabaseAnonKey: '',
    developmentMode: true,
  );

  group('SupabaseService', () {
    test('reports not configured without environment credentials', () {
      final service = SupabaseService(
        config: unconfiguredConfig,
        logger: AppLogger(unconfiguredConfig),
      );

      expect(service.isConfigured, isFalse);
      expect(service.isInitialized, isFalse);
    });

    test('skips Supabase credential check in development mode', () {
      final service = SupabaseService(
        config: developmentConfig,
        logger: AppLogger(developmentConfig),
      );

      expect(service.isConfigured, isFalse);
      expect(service.isInitialized, isFalse);
    });

    test('throws when accessing client without configuration', () {
      final service = SupabaseService(
        config: unconfiguredConfig,
        logger: AppLogger(unconfiguredConfig),
      );

      expect(() => service.client, throwsA(isA<SupabaseNotConfiguredException>()));
    });
  });

  group('AuthService', () {
    test('returns unauthenticated state when Supabase is unavailable', () async {
      final supabaseService = SupabaseService(
        config: unconfiguredConfig,
        logger: AppLogger(unconfiguredConfig),
      );
      final authService = AuthService(supabaseService);

      expect(authService.isAvailable, isFalse);
      expect(authService.currentAuthState, isA<AuthUnauthenticated>());

      final states = await authService.watchAuthState().take(1).toList();
      expect(states.single, isA<AuthUnauthenticated>());
    });
  });

  group('AuthRepository', () {
    late Directory tempDir;
    late StorageHelper storageHelper;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('auth_repo_test');
      storageHelper = StorageHelper(AppLogger(unconfiguredConfig));
      await storageHelper.init(path: tempDir.path);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    AuthRemoteDataSource buildRemoteDataSource(AppConfig config) {
      return SupabaseAuthRemoteDataSource(
        AuthService(
          SupabaseService(
            config: config,
            logger: AppLogger(config),
          ),
        ),
      );
    }

    test('unconfigured repository rejects sign in', () async {
      final repository = createAuthRepository(
        isSupabaseReady: false,
        remoteDataSource: buildRemoteDataSource(unconfiguredConfig),
        config: unconfiguredConfig,
        storageHelper: storageHelper,
      );

      expect(
        () => repository.signIn(email: 'a@b.com', password: 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('development mode uses local auth repository', () async {
      final repository = createAuthRepository(
        isSupabaseReady: false,
        remoteDataSource: buildRemoteDataSource(developmentConfig),
        config: developmentConfig,
        storageHelper: storageHelper,
      );

      expect(repository, isA<LocalDevAuthRepository>());

      await repository.signIn(
        email: 'test@gmail.com',
        password: 'Test@123456',
      );

      expect(repository.currentAuthState.isAuthenticated, isTrue);
    });
  });
}
