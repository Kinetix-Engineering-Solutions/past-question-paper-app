import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('accepts an HTTPS API URL', () {
      final config = AppConfig.fromBaseUrl('https://api.example.com');

      expect(config.contentApiBaseUri, Uri.parse('https://api.example.com'));
    });

    test('accepts a local HTTP API URL', () {
      final config = AppConfig.fromBaseUrl('http://localhost:5038');

      expect(config.contentApiBaseUri, Uri.parse('http://localhost:5038'));
    });

    test('trims surrounding whitespace', () {
      final config = AppConfig.fromBaseUrl('  https://api.example.com  ');

      expect(config.contentApiBaseUri, Uri.parse('https://api.example.com'));
    });

    test('rejects an empty API URL', () {
      expect(() => AppConfig.fromBaseUrl(''), throwsStateError);
    });

    test('rejects a relative URL', () {
      expect(() => AppConfig.fromBaseUrl('/api'), throwsArgumentError);
    });

    test('rejects an unsupported URL scheme', () {
      expect(
        () => AppConfig.fromBaseUrl('ftp://api.example.com'),
        throwsArgumentError,
      );
    });
  });
}
