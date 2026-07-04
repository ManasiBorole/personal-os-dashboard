import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_params.dart';

abstract interface class SettingsRepository {
  Future<UserProfile> getUserProfile({required String userId, String? email});

  Future<UserProfile> updateUserProfile({
    required String userId,
    required String email,
    required UpdateUserProfileParams params,
  });

  Future<AppPreferences> getPreferences();

  Future<AppPreferences> updatePreferences(AppPreferences preferences);

  Future<BackupSummary> createBackup({required String userId});
}
