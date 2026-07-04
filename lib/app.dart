import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/notifications/notification_bootstrap.dart';
import 'package:personal_os_dashboard/core/router/app_router.dart';
import 'package:personal_os_dashboard/core/theme/app_theme.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

/// Root application widget.
class PersonalOsApp extends ConsumerWidget {
  const PersonalOsApp({required this.appConfig, super.key});

  final AppConfig appConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return NotificationBootstrap(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: !appConfig.environment.isProd,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: [
          for (final language in AppLanguage.values) language.locale,
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}
