import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:personal_os_dashboard/core/config/env_defines.dart';

/// Reads configuration from compile-time defines, bundled `.env`, then dev fallbacks.
abstract final class EnvReader {
  static String? get(String key) {
    final compileTime = _compileTimeValue(key);
    if (compileTime != null && compileTime.isNotEmpty) {
      return compileTime;
    }

    try {
      final fromDotenv = dotenv.env[key];
      if (fromDotenv != null && fromDotenv.isNotEmpty) {
        return fromDotenv;
      }
    } on Object {
      // dotenv may be unavailable before load() or on missing asset.
    }

    return _devFallback(key);
  }

  static String getOrEmpty(String key) => get(key) ?? '';

  static String? _compileTimeValue(String key) {
    return switch (key) {
      'APP_ENV' => EnvDefines.appEnv,
      'SUPABASE_URL' => EnvDefines.supabaseUrl,
      'SUPABASE_ANON_KEY' => EnvDefines.supabaseAnonKey,
      'FIREBASE_API_KEY' => EnvDefines.firebaseApiKey,
      'FIREBASE_APP_ID' => EnvDefines.firebaseAppId,
      'FIREBASE_MESSAGING_SENDER_ID' => EnvDefines.firebaseMessagingSenderId,
      'FIREBASE_PROJECT_ID' => EnvDefines.firebaseProjectId,
      'FIREBASE_STORAGE_BUCKET' => EnvDefines.firebaseStorageBucket,
      'FIREBASE_AUTH_DOMAIN' => EnvDefines.firebaseAuthDomain,
      'FIREBASE_IOS_BUNDLE_ID' => EnvDefines.firebaseIosBundleId,
      _ => '',
    };
  }

  /// Safe defaults for local development when no env file or defines are set.
  static String? _devFallback(String key) {
    return switch (key) {
      'APP_ENV' => 'dev',
      'LOCAL_AUTH_ENABLED' => 'true',
      'DEV_TEST_EMAIL' => 'test@personalos.dev',
      'DEV_TEST_PASSWORD' => 'password123',
      'SUPABASE_URL' => '',
      'SUPABASE_ANON_KEY' => '',
      'FIREBASE_API_KEY' => '',
      'FIREBASE_APP_ID' => '',
      'FIREBASE_MESSAGING_SENDER_ID' => '',
      'FIREBASE_PROJECT_ID' => '',
      'FIREBASE_STORAGE_BUCKET' => '',
      _ => null,
    };
  }
}
