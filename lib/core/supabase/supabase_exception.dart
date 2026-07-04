/// Thrown when Supabase operations are attempted without configuration.
final class SupabaseNotConfiguredException implements Exception {
  const SupabaseNotConfiguredException([
    this.message =
        'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in .env',
  ]);

  final String message;

  @override
  String toString() => 'SupabaseNotConfiguredException: $message';
}
