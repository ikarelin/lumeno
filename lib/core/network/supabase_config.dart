abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static void validate() {
    if (url.isEmpty) {
      throw StateError(
        'SUPABASE_URL is not configured. '
        'Run the app with --dart-define-from-file.',
      );
    }

    if (publishableKey.isEmpty) {
      throw StateError(
        'SUPABASE_PUBLISHABLE_KEY is not configured. '
        'Run the app with --dart-define-from-file.',
      );
    }
  }
}
