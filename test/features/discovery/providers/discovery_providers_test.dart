import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:past_question_paper_v1/core/network/api_client.dart';
import 'package:past_question_paper_v1/features/discovery/data/discovery_repository.dart';
import 'package:past_question_paper_v1/features/discovery/providers/discovery_providers.dart';

void main() {
  test('discovery controller loads repository data', () async {
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

    final container = ProviderContainer(
      overrides: [discoveryRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final result = await container.read(discoveryControllerProvider.future);

    expect(result.subjects.single.name, 'Physical Sciences');
    expect(result.topics.single.name, 'Newtonian Mechanics');
  });
}
