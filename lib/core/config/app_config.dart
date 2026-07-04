import 'package:personal_os_dashboard/core/config/env_reader.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';

/// Centralized runtime configuration loaded from environment variables.
final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppConfig.fromEnv() {
    final environmentName =
        EnvReader.get('APP_ENV') ?? AppEnvironment.dev.name;

    return AppConfig(
      environment: AppEnvironment.fromString(environmentName),
      supabaseUrl: EnvReader.getOrEmpty('SUPABASE_URL'),
      supabaseAnonKey: EnvReader.getOrEmpty('SUPABASE_ANON_KEY'),
    );
  }

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
