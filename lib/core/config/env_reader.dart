import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads configuration from compile-time defines first, then bundled `.env`.
abstract final class EnvReader {
  static String? get(String key) {
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    try {
      return dotenv.env[key];
    } on Object {
      return null;
    }
  }

  static String getOrEmpty(String key) => get(key) ?? '';
}
