import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:personal_os_dashboard/core/config/environment.dart';

/// Centralized runtime configuration loaded from environment variables.
final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppConfig.fromEnv() {
    final environmentName = dotenv.env['APP_ENV'] ?? AppEnvironment.dev.name;

    return AppConfig(
      environment: AppEnvironment.fromString(environmentName),
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
