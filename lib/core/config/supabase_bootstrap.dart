import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';

/// Initializes Supabase when credentials are available.
Future<void> initializeSupabase({
  required AppConfig config,
  required AppLogger logger,
}) async {
  if (!config.hasSupabaseCredentials) {
    logger.warning(
      'Supabase credentials missing. Authentication routes will be limited.',
    );
    return;
  }

  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey, // ignore: deprecated_member_use
  );

  logger.info('Supabase initialized');
}
