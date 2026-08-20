import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:past_question_paper_v1/core/network/api_client.dart';
import 'package:past_question_paper_v1/features/discovery/data/discovery_repository.dart';

void main() {
  group('DiscoveryRepository', () {
    test('combines subjects and Grade 12 topics', () async {
      final httpClient = MockClient((request) async {
        if (request.url.path == '/api/subjects') {
          return http.Response('''
            [
              {
                "id": "subject-id",
                "name": "Physical Sciences",
                "slug": "physical-sciences"
              }
            ]
            ''', 200);
        }

        expect(request.url.path, '/api/topics');
        expect(request.url.queryParameters['grade'], '12');

        return http.Response('''
          [
            {
              "id": "topic-id",
              "name": "Newtonian Mechanics",
              "slug": "newtonian-mechanics",
              "grade": 12,
              "displayOrder": 1,
              "subjectId": "subject-id",
              "subjectName": "Physical Sciences",
              "subjectSlug": "physical-sciences",
              "questionCount": 2
            }
          ]
          ''', 200);
      });

      final repository = DiscoveryRepository(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: httpClient,
        ),
      );

      final result = await repository.getGrade12Discovery();

      expect(result.subjects, hasLength(1));
      expect(result.topics, hasLength(1));
      expect(
        result.topicsForSubject('subject-id').single.name,
        'Newtonian Mechanics',
      );
    });

    test('returns empty discovery data for empty responses', () async {
      final repository = DiscoveryRepository(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((_) async => http.Response('[]', 200)),
        ),
      );

      final result = await repository.getGrade12Discovery();

      expect(result.isEmpty, isTrue);
    });

    test('rejects a topic with an unknown subject', () async {
      final httpClient = MockClient((request) async {
        if (request.url.path == '/api/subjects') {
          return http.Response('[]', 200);
        }

        return http.Response('''
          [
            {
              "id": "topic-id",
              "name": "Newtonian Mechanics",
              "slug": "newtonian-mechanics",
              "grade": 12,
              "displayOrder": 1,
              "subjectId": "unknown-subject",
              "subjectName": "Physical Sciences",
              "subjectSlug": "physical-sciences",
              "questionCount": 2
            }
          ]
          ''', 200);
      });

      final repository = DiscoveryRepository(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: httpClient,
        ),
      );

      expect(repository.getGrade12Discovery, throwsA(isA<Exception>()));
    });
  });
}
