final class AppConfig {
  const AppConfig._({required this.contentApiBaseUri});

  final Uri contentApiBaseUri;

  factory AppConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment('CONTENT_API_BASE_URL');

    return AppConfig.fromBaseUrl(baseUrl);
  }

  factory AppConfig.fromBaseUrl(String baseUrl) {
    final normalisedValue = baseUrl.trim();

    if (normalisedValue.isEmpty) {
      throw StateError(
        'CONTENT_API_BASE_URL is not configured. '
        'Provide it using --dart-define.',
      );
    }

    final uri = Uri.tryParse(normalisedValue);

    if (uri == null ||
        !uri.isAbsolute ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ArgumentError.value(
        baseUrl,
        'CONTENT_API_BASE_URL',
        'Must be an absolute HTTP or HTTPS URL.',
      );
    }

    return AppConfig._(contentApiBaseUri: uri);
  }
}
