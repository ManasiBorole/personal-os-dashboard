/// Local storage keys, Hive box names, and cache identifiers.
abstract final class StorageConstants {
  // Hive boxes
  static const String cacheBox = 'personal_os_cache';
  static const String settingsBox = 'personal_os_settings';

  // Preference keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastSyncTimestampKey = 'last_sync_timestamp';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String sessionExpiryKey = 'session_expiry';
  static const String fcmTokenKey = 'fcm_token';

  // Cache keys
  static const String userProfileCacheKey = 'user_profile';
  static const String dashboardCacheKey = 'dashboard_data';
}
