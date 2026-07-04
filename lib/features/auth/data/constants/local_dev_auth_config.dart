import 'package:personal_os_dashboard/core/config/env_reader.dart';

/// Local development authentication defaults when Supabase is unavailable.
abstract final class LocalDevAuthConfig {
  static const defaultTestEmail = 'test@personalos.dev';
  static const defaultTestPassword = 'password123';

  static String get testEmail =>
      EnvReader.get('DEV_TEST_EMAIL') ?? defaultTestEmail;

  static String get testPassword =>
      EnvReader.get('DEV_TEST_PASSWORD') ?? defaultTestPassword;

  static bool get isEnabled {
    final flag = EnvReader.get('LOCAL_AUTH_ENABLED');
    return flag == null || flag.isEmpty || flag.toLowerCase() == 'true';
  }
}
