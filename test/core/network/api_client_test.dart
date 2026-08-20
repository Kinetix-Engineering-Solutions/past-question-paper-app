import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:past_question_paper_v1/core/network/api_client.dart';
import 'package:past_question_paper_v1/core/network/api_exception.dart';

void main() {
  group('ApiClient', () {
    test('returns decoded JSON for a successful request', () async {
      final httpClient = MockClient((request) async {
        expect(request.url.toString(), 'https://api.example.com/api/subjects');

        return http.Response('[{"id":"1","name":"Mathematics"}]', 200);
      });

      final apiClient = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: httpClient,
      );

      final result = await apiClient.get('/api/subjects');

      expect(result, isA<List<Object?>>());
    });

    test('includes query parameters', () async {
      final httpClient = MockClient((request) async {
        expect(request.url.path, '/api/topics');
        expect(request.url.queryParameters['grade'], '12');

        return http.Response('[]', 200);
      });

      final apiClient = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: httpClient,
      );

      await apiClient.get('/api/topics', queryParameters: {'grade': '12'});
    });

    test('throws an HTTP failure for non-success status', () async {
      final httpClient = MockClient((_) async => http.Response('{}', 500));

      final apiClient = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: httpClient,
      );

      expect(
        () => apiClient.get('/api/subjects'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiFailureType.http)
              .having((error) => error.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('throws an invalid-response failure for malformed JSON', () {
      final httpClient = MockClient(
        (_) async => http.Response('not-json', 200),
      );

      final apiClient = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: httpClient,
      );

      expect(
        () => apiClient.get('/api/subjects'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.invalidResponse,
          ),
        ),
      );
    });
  });
}
