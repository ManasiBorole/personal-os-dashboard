import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// App theme preference.
enum AppThemePreference {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemePreference(this.label);

  final String label;

  ThemeMode get themeMode => switch (this) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };

  static AppThemePreference fromString(String? value) {
    return AppThemePreference.values.firstWhere(
      (mode) => mode.name == value?.toLowerCase(),
      orElse: () => AppThemePreference.system,
    );
  }
}

/// Supported app languages.
enum AppLanguage {
  english('en', 'US', 'English'),
  spanish('es', 'ES', 'Español'),
  french('fr', 'FR', 'Français');

  const AppLanguage(this.languageCode, this.countryCode, this.label);

  final String languageCode;
  final String countryCode;
  final String label;

  Locale get locale => Locale(languageCode, countryCode);

  static AppLanguage fromLocale(Locale locale) {
    return AppLanguage.values.firstWhere(
      (lang) =>
          lang.languageCode == locale.languageCode &&
          lang.countryCode == locale.countryCode,
      orElse: () => AppLanguage.english,
    );
  }

  static AppLanguage fromStorage(String? value) {
    if (value == null || value.isEmpty) return AppLanguage.english;
    final parts = value.split('_');
    return fromLocale(Locale(parts.first, parts.length > 1 ? parts[1] : ''));
  }

  String get storageValue => '${languageCode}_$countryCode';
}

/// User-editable profile fields.
final class UserProfile extends Entity {
  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.bio,
    required this.avatarUrl,
    required this.updatedAt,
  });

  final String userId;
  final String displayName;
  final String email;
  final String? phone;
  final String bio;
  final String? avatarUrl;
  final DateTime updatedAt;

  String get initials {
    final source = displayName.isNotEmpty
        ? displayName
        : (email.isNotEmpty ? email : 'U');
    final parts = source.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return source.substring(0, 1).toUpperCase();
  }

  UserProfile copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
    DateTime? updatedAt,
    bool clearPhone = false,
    bool clearAvatarUrl = false,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      bio: bio ?? this.bio,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [userId, displayName, email, phone, bio, avatarUrl, updatedAt];
}

/// Application preferences and toggles.
final class AppPreferences extends Entity {
  const AppPreferences({
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.biometricEnabled,
    required this.autoBackupEnabled,
    required this.analyticsEnabled,
    required this.profileVisible,
    required this.lastBackupAt,
  });

  final AppThemePreference theme;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool autoBackupEnabled;
  final bool analyticsEnabled;
  final bool profileVisible;
  final DateTime? lastBackupAt;

  AppPreferences copyWith({
    AppThemePreference? theme,
    AppLanguage? language,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? autoBackupEnabled,
    bool? analyticsEnabled,
    bool? profileVisible,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
  }) {
    return AppPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      profileVisible: profileVisible ?? this.profileVisible,
      lastBackupAt:
          clearLastBackupAt ? null : (lastBackupAt ?? this.lastBackupAt),
    );
  }

  @override
  List<Object?> get props => [
        theme,
        language,
        notificationsEnabled,
        biometricEnabled,
        autoBackupEnabled,
        analyticsEnabled,
        profileVisible,
        lastBackupAt,
      ];
}

/// Backup export summary.
final class BackupSummary extends Entity {
  const BackupSummary({
    required this.exportedAt,
    required this.itemCount,
    required this.payload,
  });

  final DateTime exportedAt;
  final int itemCount;
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [exportedAt, itemCount, payload];
}
