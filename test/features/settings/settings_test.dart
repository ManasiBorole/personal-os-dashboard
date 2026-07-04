import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_params.dart';

void main() {
  late StorageHelper storageHelper;
  late SettingsRepositoryImpl repository;

  setUp(() async {
    const config = AppConfig(
      environment: AppEnvironment.dev,
      supabaseUrl: '',
      supabaseAnonKey: '',
      developmentMode: false,
    );
    storageHelper = StorageHelper(AppLogger(config));
    await storageHelper.init(
      path: '/tmp/settings_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = SettingsRepositoryImpl(storageHelper);
  });

  group('SettingsRepository', () {
    test('returns default profile and preferences', () async {
      final profile = await repository.getUserProfile(
        userId: 'local-user',
        email: 'alex@example.com',
      );
      final preferences = await repository.getPreferences();

      expect(profile.email, 'alex@example.com');
      expect(profile.displayName, isNotEmpty);
      expect(preferences.theme, AppThemePreference.system);
      expect(preferences.language, AppLanguage.english);
      expect(preferences.notificationsEnabled, isTrue);
    });

    test('updates profile and preferences', () async {
      final updatedProfile = await repository.updateUserProfile(
        userId: 'local-user',
        email: 'alex@example.com',
        params: const UpdateUserProfileParams(
          displayName: 'Alex Chen',
          phone: '+1 555-0100',
          bio: 'Product builder',
        ),
      );

      final updatedPreferences = await repository.updatePreferences(
        const AppPreferences(
          theme: AppThemePreference.dark,
          language: AppLanguage.spanish,
          notificationsEnabled: false,
          biometricEnabled: true,
          autoBackupEnabled: true,
          analyticsEnabled: false,
          profileVisible: false,
          lastBackupAt: null,
        ),
      );

      final loadedProfile = await repository.getUserProfile(
        userId: 'local-user',
        email: 'alex@example.com',
      );
      final loadedPreferences = await repository.getPreferences();

      expect(updatedProfile.displayName, 'Alex Chen');
      expect(loadedProfile.bio, 'Product builder');
      expect(updatedPreferences.theme, AppThemePreference.dark);
      expect(loadedPreferences.language, AppLanguage.spanish);
      expect(loadedPreferences.biometricEnabled, isTrue);
    });

    test('creates backup snapshot', () async {
      final summary = await repository.createBackup(userId: 'local-user');

      expect(summary.itemCount, greaterThan(0));
      expect(summary.payload['userId'], 'local-user');

      final preferences = await repository.getPreferences();
      expect(preferences.lastBackupAt, isNotNull);
    });
  });
}
