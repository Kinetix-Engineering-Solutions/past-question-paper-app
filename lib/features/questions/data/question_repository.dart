import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/pagination/paged_response.dart';
import 'models/question.dart';

final class QuestionRepository {
  const QuestionRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PagedResponse<Question>> getQuestions({
    required String topicId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final normalisedTopicId = topicId.trim();

    if (normalisedTopicId.isEmpty) {
      throw ArgumentError.value(topicId, 'topicId', 'A topic ID is required.');
    }

    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Page must be at least 1.');
    }

    if (pageSize < 1 || pageSize > 100) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Page size must be between 1 and 100.',
      );
    }

    final response = await _apiClient.get(
      '/api/questions',
      queryParameters: {
        'topicId': normalisedTopicId,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    if (response is! Map) {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'The server returned invalid question data.',
      );
    }

    try {
      return PagedResponse<Question>.fromJson(
        Map<String, Object?>.from(response),
        Question.fromJson,
      );
    } on FormatException {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'The server returned invalid question data.',
      );
    }
  }
}
