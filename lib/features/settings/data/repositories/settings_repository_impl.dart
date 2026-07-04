import 'package:personal_os_dashboard/core/constants/storage_constants.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_params.dart';
import 'package:personal_os_dashboard/features/settings/domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storageHelper);

  final StorageHelper _storageHelper;

  @override
  Future<UserProfile> getUserProfile({
    required String userId,
    String? email,
  }) async {
    final cacheKey = '${StorageConstants.userProfileCacheKey}_$userId';
    final cached = _storageHelper.readCache<Map<dynamic, dynamic>>(cacheKey);
    if (cached != null) {
      return _profileFromMap(userId, cached, email);
    }

    return UserProfile(
      userId: userId,
      displayName: _defaultDisplayName(email),
      email: email ?? '',
      phone: null,
      bio: '',
      avatarUrl: null,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> updateUserProfile({
    required String userId,
    required String email,
    required UpdateUserProfileParams params,
  }) async {
    final profile = UserProfile(
      userId: userId,
      displayName: params.displayName.trim(),
      email: email,
      phone: params.phone?.trim().isEmpty == true ? null : params.phone?.trim(),
      bio: params.bio.trim(),
      avatarUrl: null,
      updatedAt: DateTime.now(),
    );

    final cacheKey = '${StorageConstants.userProfileCacheKey}_$userId';
    await _storageHelper.writeCache(cacheKey, _profileToMap(profile));
    return profile;
  }

  @override
  Future<AppPreferences> getPreferences() async {
    return AppPreferences(
      theme: AppThemePreference.fromString(
        _storageHelper.readSetting<String>(StorageConstants.themeModeKey),
      ),
      language: AppLanguage.fromStorage(
        _storageHelper.readSetting<String>(StorageConstants.localeKey),
      ),
      notificationsEnabled:
          _storageHelper.readSetting<bool>(StorageConstants.notificationsEnabledKey) ??
              true,
      biometricEnabled:
          _storageHelper.readSetting<bool>(StorageConstants.biometricEnabledKey) ??
              false,
      autoBackupEnabled:
          _storageHelper.readSetting<bool>(StorageConstants.autoBackupEnabledKey) ??
              false,
      analyticsEnabled:
          _storageHelper.readSetting<bool>(StorageConstants.analyticsEnabledKey) ??
              true,
      profileVisible:
          _storageHelper.readSetting<bool>(StorageConstants.profileVisibilityKey) ??
              true,
      lastBackupAt: _parseDate(
        _storageHelper.readSetting<String>(StorageConstants.lastSyncTimestampKey),
      ),
    );
  }

  @override
  Future<AppPreferences> updatePreferences(AppPreferences preferences) async {
    await _storageHelper.writeSetting(
      StorageConstants.themeModeKey,
      preferences.theme.name,
    );
    await _storageHelper.writeSetting(
      StorageConstants.localeKey,
      preferences.language.storageValue,
    );
    await _storageHelper.writeSetting(
      StorageConstants.notificationsEnabledKey,
      preferences.notificationsEnabled,
    );
    await _storageHelper.writeSetting(
      StorageConstants.biometricEnabledKey,
      preferences.biometricEnabled,
    );
    await _storageHelper.writeSetting(
      StorageConstants.autoBackupEnabledKey,
      preferences.autoBackupEnabled,
    );
    await _storageHelper.writeSetting(
      StorageConstants.analyticsEnabledKey,
      preferences.analyticsEnabled,
    );
    await _storageHelper.writeSetting(
      StorageConstants.profileVisibilityKey,
      preferences.profileVisible,
    );
    if (preferences.lastBackupAt != null) {
      await _storageHelper.writeSetting(
        StorageConstants.lastSyncTimestampKey,
        preferences.lastBackupAt!.toIso8601String(),
      );
    }
    return preferences;
  }

  @override
  Future<BackupSummary> createBackup({required String userId}) async {
    final profile = await getUserProfile(userId: userId);
    final preferences = await getPreferences();
    final exportedAt = DateTime.now();

    final payload = {
      'userId': userId,
      'profile': _profileToMap(profile),
      'preferences': {
        'theme': preferences.theme.name,
        'language': preferences.language.storageValue,
        'notificationsEnabled': preferences.notificationsEnabled,
        'biometricEnabled': preferences.biometricEnabled,
        'autoBackupEnabled': preferences.autoBackupEnabled,
        'analyticsEnabled': preferences.analyticsEnabled,
        'profileVisible': preferences.profileVisible,
      },
      'exportedAt': exportedAt.toIso8601String(),
    };

    await updatePreferences(preferences.copyWith(lastBackupAt: exportedAt));

    return BackupSummary(
      exportedAt: exportedAt,
      itemCount: payload.length,
      payload: payload,
    );
  }

  String _defaultDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'User';
    final local = email.split('@').first;
    return local.replaceAll('.', ' ').replaceAll('_', ' ');
  }

  UserProfile _profileFromMap(
    String userId,
    Map<dynamic, dynamic> map,
    String? email,
  ) {
    return UserProfile(
      userId: userId,
      displayName: map['displayName']?.toString() ?? _defaultDisplayName(email),
      email: map['email']?.toString() ?? email ?? '',
      phone: map['phone']?.toString(),
      bio: map['bio']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString(),
      updatedAt: _parseDate(map['updatedAt']?.toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _profileToMap(UserProfile profile) {
    return {
      'displayName': profile.displayName,
      'email': profile.email,
      'phone': profile.phone,
      'bio': profile.bio,
      'avatarUrl': profile.avatarUrl,
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

SettingsRepository createSettingsRepository({
  required StorageHelper storageHelper,
}) {
  return SettingsRepositoryImpl(storageHelper);
}
