import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';

/// Result of loading bundled development environment variables.
final class EnvBootstrapResult {
  const EnvBootstrapResult({
    required this.loadedFromAsset,
    this.loadError,
  });

  final bool loadedFromAsset;
  final Object? loadError;

  bool get hasLoadError => loadError != null;
}

/// Loads environment configuration for app startup.
abstract final class EnvBootstrap {
  static const developmentAsset = 'assets/env/development.env';

  /// Loads bundled development env. Safe when Supabase/Firebase keys are empty.
  static Future<EnvBootstrapResult> load() async {
    try {
      await dotenv.load(fileName: developmentAsset);
      _log('Loaded $developmentAsset');
      return const EnvBootstrapResult(loadedFromAsset: true);
    } on Object catch (error, stackTrace) {
      _log('Failed to load $developmentAsset: $error', stackTrace: stackTrace);
      return EnvBootstrapResult(
        loadedFromAsset: false,
        loadError: error,
      );
    }
  }

  /// Logs resolved startup configuration for diagnostics.
  static void logStartupConfig(
    AppConfig config, {
    EnvBootstrapResult? bootstrap,
    AppLogger? logger,
  }) {
    final dotenvStatus = bootstrap == null
        ? 'unknown'
        : bootstrap.loadedFromAsset
            ? 'loaded'
            : 'fallback';

    final message =
        'Startup config [${config.environment.name}] | '
        'dotenv=$dotenvStatus | '
        'developmentMode=${config.isDevelopmentMode ? 'enabled' : 'disabled'} | '
        'supabase=${config.hasSupabaseCredentials ? 'enabled' : 'disabled (local mode)'} | '
        'localAuth=${config.isLocalAuthMode ? 'enabled' : 'disabled'} | '
        'firebase=${_hasFirebaseConfig() ? 'configured' : 'disabled'}';

    if (logger != null) {
      if (bootstrap?.hasLoadError ?? false) {
        logger.warning(
          message,
          error: bootstrap!.loadError,
        );
      } else {
        logger.info(message);
      }
      return;
    }

    debugPrint('[EnvBootstrap] $message');
    if (bootstrap?.hasLoadError ?? false) {
      debugPrint('[EnvBootstrap] Load error: ${bootstrap!.loadError}');
    }
  }

  static bool _hasFirebaseConfig() {
    try {
      final apiKey = dotenv.env['FIREBASE_API_KEY'];
      final appId = dotenv.env['FIREBASE_APP_ID'];
      return apiKey != null &&
          apiKey.isNotEmpty &&
          appId != null &&
          appId.isNotEmpty;
    } on Object {
      return false;
    }
  }

  static void _log(String message, {StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('[EnvBootstrap] $message');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
