import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:past_question_paper_v1/core/network/api_client.dart';
import 'package:past_question_paper_v1/core/network/api_exception.dart';
import 'package:past_question_paper_v1/features/questions/data/question_repository.dart';

void main() {
  group('QuestionRepository', () {
    test('loads a page of questions for a topic', () async {
      final httpClient = MockClient((request) async {
        expect(request.url.path, '/api/questions');
        expect(request.url.queryParameters['topicId'], 'topic-id');
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['pageSize'], '20');

        return http.Response('''
          {
            "items": [
              {
                "id": "question-id",
                "questionNumber": "1.2",
                "displayOrder": 2,
                "examYear": 2022,
                "examSeason": "May-June",
                "paperNumber": 1,
                "questionImageUrl":
                  "https://example.com/question.webp",
                "memoImageUrl":
                  "https://example.com/memo.webp",
                "topicId": "topic-id",
                "topicName": "Newtonian Mechanics",
                "topicSlug": "newtonian-mechanics",
                "grade": 12,
                "subjectId": "subject-id",
                "subjectName": "Physical Sciences",
                "subjectSlug": "physical-sciences"
              }
            ],
            "page": 1,
            "pageSize": 20,
            "totalCount": 1,
            "totalPages": 1
          }
          ''', 200);
      });

      final repository = QuestionRepository(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: httpClient,
        ),
      );

      final result = await repository.getQuestions(topicId: 'topic-id');

      expect(result.items, hasLength(1));
      expect(result.items.single.questionNumber, '1.2');
      expect(result.totalCount, 1);
    });

    test('rejects an empty topic ID', () {
      final repository = QuestionRepository(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((_) async => http.Response('{}', 200)),
        ),
      );

      expect(() => repository.getQuestions(topicId: ''), throwsArgumentError);
    });

    test('rejects an invalid response shape', () {
      final repository = QuestionRepository(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((_) async => http.Response('[]', 200)),
        ),
      );

      expect(
        () => repository.getQuestions(topicId: 'topic-id'),
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
