import 'package:past_question_paper_v1/core/shared/models/rest_api_question.dart';
import 'package:past_question_paper_v1/core/shared/models/flashcard_question.dart';
import 'package:past_question_paper_v1/core/shared/models/rest_question_query.dart';
import 'package:past_question_paper_v1/core/shared/services/rest_questions_api_service.dart';

class RestQuestionsRepository {
  final RestQuestionsApiService _service;
  final int _retryCount;
  final Map<String, List<FlashcardQuestion>> _flashcardCache =
      <String, List<FlashcardQuestion>>{};

  RestQuestionsRepository({
    RestQuestionsApiService? service,
    int retryCount = 1,
  }) : _service = service ?? RestQuestionsApiService(),
       _retryCount = retryCount;

  Future<List<RestApiQuestion>> fetchQuestions(
    RestQuestionQuery query, {
    int limit = 50,
    int offset = 0,
    Duration timeout = const Duration(seconds: 8),
  }) {
    return _service.fetchQuestionsForQuery(
      query,
      limit: limit,
      offset: offset,
      timeout: timeout,
    );
  }

  Future<List<FlashcardQuestion>> fetchFlashcardQuestions(
    RestQuestionQuery query, {
    int limit = 50,
    int offset = 0,
    Duration timeout = const Duration(seconds: 8),
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${query.cacheKey}&limit=$limit&offset=$offset';
    if (!forceRefresh) {
      final cached = _flashcardCache[cacheKey];
      if (cached != null) {
        return List<FlashcardQuestion>.unmodifiable(cached);
      }
    }

    final apiQuestions = await _fetchWithRetry(
      query,
      limit: limit,
      offset: offset,
      timeout: timeout,
    );
    final questions = apiQuestions.map(_toFlashcardQuestion).toList();
    final cachedQuestions = List<FlashcardQuestion>.unmodifiable(questions);
    _flashcardCache[cacheKey] = cachedQuestions;
    return cachedQuestions;
  }

  Future<List<RestApiQuestion>> _fetchWithRetry(
    RestQuestionQuery query, {
    required int limit,
    required int offset,
    required Duration timeout,
  }) async {
    var attempt = 0;

    while (true) {
      try {
        return await _service.fetchQuestionsForQuery(
          query,
          limit: limit,
          offset: offset,
          timeout: timeout,
        );
      } on RestApiException catch (error) {
        if (attempt >= _retryCount || !_shouldRetry(error)) {
          rethrow;
        }
        attempt += 1;
      }
    }
  }

  bool _shouldRetry(RestApiException error) {
    final statusCode = error.statusCode;
    return statusCode == null || statusCode >= 500;
  }

  FlashcardQuestion _toFlashcardQuestion(RestApiQuestion question) {
    return FlashcardQuestion(
      id: question.id,
      subjectId: question.subjectId,
      grade: question.grade,
      topic: question.topic,
      year: question.year,
      season: question.season,
      paper: question.paper,
      questionNumber: question.questionNumber,
      questionImageUrl: question.imageUrl,
      answerImageUrl: question.answerImageUrl,
    );
  }
}
