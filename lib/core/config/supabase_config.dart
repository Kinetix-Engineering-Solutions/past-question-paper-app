final class SupabaseConfig {
  const SupabaseConfig._({required this.url, required this.publishableKey});

  final Uri url;
  final String publishableKey;

  factory SupabaseConfig.fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL');

    const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    return SupabaseConfig.fromValues(url: url, publishableKey: publishableKey);
  }

  factory SupabaseConfig.fromValues({
    required String url,
    required String publishableKey,
  }) {
    final normalisedUrl = url.trim();
    final normalisedKey = publishableKey.trim();
    final uri = Uri.tryParse(normalisedUrl);

    if (uri == null ||
        !uri.isAbsolute ||
        uri.scheme != 'https' ||
        uri.host.isEmpty) {
      throw ArgumentError.value(
        url,
        'SUPABASE_URL',
        'Must be an absolute HTTPS URL.',
      );
    }

    if (normalisedKey.isEmpty) {
      throw StateError('SUPABASE_PUBLISHABLE_KEY is not configured.');
    }

    return SupabaseConfig._(url: uri, publishableKey: normalisedKey);
  }
}
