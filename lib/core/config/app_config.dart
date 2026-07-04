import 'package:personal_os_dashboard/core/config/env_reader.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';

/// Centralized runtime configuration loaded from environment variables.
final class AppConfig {
  factory AppConfig.fromEnv() {
    final environmentName =
        EnvReader.get('APP_ENV') ?? AppEnvironment.dev.name;

    return AppConfig(
      environment: AppEnvironment.fromString(environmentName),
      supabaseUrl: EnvReader.getOrEmpty('SUPABASE_URL'),
      supabaseAnonKey: EnvReader.getOrEmpty('SUPABASE_ANON_KEY'),
      developmentMode: EnvReader.isDevelopmentMode,
    );
  }

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.developmentMode,
  });

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool developmentMode;

  bool get hasSupabaseCredentials =>
      !developmentMode &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  /// Offline mock authentication — skips Supabase Auth entirely.
  bool get isDevelopmentMode => developmentMode;

  /// Uses offline auth when Supabase is unavailable in development.
  bool get isLocalAuthMode =>
      developmentMode || (environment.isDev && !hasSupabaseCredentials);
}
