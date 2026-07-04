import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_exception.dart';

/// Central Supabase client manager for auth, database, and storage access.
final class SupabaseService {
  SupabaseService({
    required AppConfig config,
    required AppLogger logger,
  })  : _config = config,
        _logger = logger;

  final AppConfig _config;
  final AppLogger _logger;

  bool _isInitialized = false;

  /// Whether environment variables contain Supabase credentials.
  bool get isConfigured => _config.hasSupabaseCredentials;

  /// Whether [initialize] completed successfully.
  bool get isInitialized => _isInitialized;

  /// Initializes the Supabase Flutter SDK using environment configuration.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (!isConfigured) {
      _logger.warning(
        'Supabase credentials missing. Remote services are disabled.',
      );
      return;
    }

    await Supabase.initialize(
      url: _config.supabaseUrl,
      anonKey: _config.supabaseAnonKey, // ignore: deprecated_member_use
    );

    _isInitialized = true;
    _logger.info('Supabase client initialized');
  }

  /// Raw Supabase client for advanced use cases.
  SupabaseClient get client {
    _ensureReady();
    return Supabase.instance.client;
  }

  /// Authentication client (GoTrue).
  GoTrueClient get auth {
    _ensureReady();
    return client.auth;
  }

  /// Storage client for file operations.
  SupabaseStorageClient get storage {
    _ensureReady();
    return client.storage;
  }

  /// Returns a PostgREST query builder for the given [table].
  SupabaseQueryBuilder from(String table) {
    _ensureReady();
    return client.from(table);
  }

  /// Executes a Postgres function via RPC.
  PostgrestFilterBuilder<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) {
    _ensureReady();
    return client.rpc(functionName, params: params);
  }

  void _ensureReady() {
    if (!isConfigured) {
      throw const SupabaseNotConfiguredException();
    }

    if (!_isInitialized) {
      throw const SupabaseNotConfiguredException(
        'Supabase client is not initialized. Call initialize() first.',
      );
    }
  }
}
