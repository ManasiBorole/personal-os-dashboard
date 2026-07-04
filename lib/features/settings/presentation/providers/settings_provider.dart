import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_params.dart';
import 'package:personal_os_dashboard/features/settings/domain/usecases/settings_usecases.dart';

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(settingsRepositoryProvider));
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return UpdateUserProfileUseCase(ref.watch(settingsRepositoryProvider));
});

final getAppPreferencesUseCaseProvider = Provider<GetAppPreferencesUseCase>((ref) {
  return GetAppPreferencesUseCase(ref.watch(settingsRepositoryProvider));
});

final updateAppPreferencesUseCaseProvider =
    Provider<UpdateAppPreferencesUseCase>((ref) {
  return UpdateAppPreferencesUseCase(ref.watch(settingsRepositoryProvider));
});

final createBackupUseCaseProvider = Provider<CreateBackupUseCase>((ref) {
  return CreateBackupUseCase(ref.watch(settingsRepositoryProvider));
});

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final preferences = ref.watch(appPreferencesProvider);
    return preferences.maybeWhen(
      data: (prefs) => prefs.theme.themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTheme(AppThemePreference theme) async {
    final current = await ref.read(appPreferencesProvider.future);
    final updated = current.copyWith(theme: theme);
    await ref.read(appPreferencesProvider.notifier).save(updated);
    state = theme.themeMode;
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final preferences = ref.watch(appPreferencesProvider);
    return preferences.maybeWhen(
      data: (prefs) => prefs.language.locale,
      orElse: () => AppLanguage.english.locale,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    final current = await ref.read(appPreferencesProvider.future);
    final updated = current.copyWith(language: language);
    await ref.read(appPreferencesProvider.notifier).save(updated);
    state = language.locale;
  }
}

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferences>(
  AppPreferencesController.new,
);

class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() async => _load();

  Future<void> save(AppPreferences preferences) async {
    final result =
        await ref.read(updateAppPreferencesUseCaseProvider).call(preferences);
    result.when(
      success: (prefs) {
        state = AsyncData(prefs);
        ref.invalidate(themeModeProvider);
        ref.invalidate(localeProvider);
      },
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }

  Future<AppPreferences> _load() async {
    final result =
        await ref.read(getAppPreferencesUseCaseProvider).call(const NoParams());
    return result.when(
      success: (prefs) => prefs,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileController, UserProfile>(
  UserProfileController.new,
);

class UserProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<bool> updateProfile(UpdateUserProfileParams params) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? 'local-user';
    final email = user?.email ?? '';

    final result = await ref.read(updateUserProfileUseCaseProvider).call((
      userId: userId,
      email: email,
      params: params,
    ));

    return result.when(
      success: (profile) {
        state = AsyncData(profile);
        return true;
      },
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }

  Future<UserProfile> _load() async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? 'local-user';
    final result = await ref.read(getUserProfileUseCaseProvider).call((
      userId: userId,
      email: user?.email,
    ));
    return result.when(
      success: (profile) => profile,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}
