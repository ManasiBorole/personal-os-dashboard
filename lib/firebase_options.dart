import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:personal_os_dashboard/core/config/env_reader.dart';

/// Firebase configuration loaded from environment variables.
///
/// Run `flutterfire configure` and copy values into `.env`, or set:
/// `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`,
/// `FIREBASE_PROJECT_ID`, and optional platform-specific IDs.
abstract final class DefaultFirebaseOptions {
  static bool get isConfigured {
    final apiKey = EnvReader.get('FIREBASE_API_KEY');
    final appId = EnvReader.get('FIREBASE_APP_ID');
    final projectId = EnvReader.get('FIREBASE_PROJECT_ID');
    return apiKey != null &&
        apiKey.isNotEmpty &&
        appId != null &&
        appId.isNotEmpty &&
        projectId != null &&
        projectId.isNotEmpty;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      _ => android,
    };
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _env('FIREBASE_API_KEY'),
        appId: _env('FIREBASE_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        storageBucket: EnvReader.get('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _env('FIREBASE_API_KEY'),
        appId: _env('FIREBASE_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        storageBucket: EnvReader.get('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: EnvReader.get('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get macos => ios;

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _env('FIREBASE_API_KEY'),
        appId: _env('FIREBASE_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        authDomain: EnvReader.get('FIREBASE_AUTH_DOMAIN'),
        storageBucket: EnvReader.get('FIREBASE_STORAGE_BUCKET'),
      );

  static String _env(String key) => EnvReader.getOrEmpty(key);
}
