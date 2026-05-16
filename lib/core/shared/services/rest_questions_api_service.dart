import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:past_question_paper_v1/core/shared/models/rest_api_question.dart';
import 'package:past_question_paper_v1/core/shared/models/rest_question_query.dart';

class RestApiException implements Exception {
  final Uri url;
  final int? statusCode;
  final String message;
  final String? responseBodyPreview;

  const RestApiException({
    required this.url,
    required this.message,
    this.statusCode,
    this.responseBodyPreview,
  });

  String toUserMessage() {
    if (statusCode == null) {
      return 'Could not connect to the question service. Check your connection and try again.';
    }

    if (statusCode == 404) {
      return 'No questions were found for the selected filters.';
    }

    if (statusCode == 429) {
      return 'The question service is busy. Please wait a moment and try again.';
    }

    if (statusCode! >= 500) {
      return 'The question service is temporarily unavailable. Please try again later.';
    }

    return 'Questions could not be loaded. Please check your filters and try again.';
  }

  @override
  String toString() {
    final status = statusCode != null ? ' (HTTP $statusCode)' : '';
    final preview =
        (responseBodyPreview != null && responseBodyPreview!.trim().isNotEmpty)
        ? '\nBody: $responseBodyPreview'
        : '';
    return '$message$status\nURL: $url$preview';
  }
}

/// Minimal REST client for the legacy Heroku endpoint:
/// GET /api/questions?subject=...&grade=...&topic=...
class RestQuestionsApiService {
  static const String defaultBaseUrl =
      'https://pastpapersapp-be1962e3bb81.herokuapp.com';

  final http.Client _client;
  final String _baseUrl;

  RestQuestionsApiService({
    http.Client? client,
    String baseUrl = defaultBaseUrl,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl;

  Future<List<RestApiQuestion>> fetchQuestions({
    required String subject,
    required int grade,
    required String topic,
    int? startYear,
    int? endYear,
    String? paper,
    String? season,
    String? questionNumber,
    String? questionPrefix,
    int limit = 50,
    int offset = 0,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    return fetchQuestionsForQuery(
      RestQuestionQuery(
        subject: subject,
        grade: grade,
        topic: topic,
        startYear: startYear,
        endYear: endYear,
        paper: paper,
        season: season,
        questionNumber: questionNumber,
        questionPrefix: questionPrefix,
      ),
      limit: limit,
      offset: offset,
      timeout: timeout,
    );
  }

  Future<List<RestApiQuestion>> fetchQuestionsForQuery(
    RestQuestionQuery query, {
    int limit = 50,
    int offset = 0,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final queryParameters = query.toQueryParameters();
    queryParameters['limit'] = limit.toString();
    queryParameters['offset'] = offset.toString();

    final url = Uri.parse(
      '$_baseUrl/api/questions',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client.get(url).timeout(timeout);

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          final list = _extractQuestionList(decoded);
          return list
              .whereType<Map>()
              .map((item) => item.cast<String, dynamic>())
              .map(RestApiQuestion.fromJson)
              .toList();
        } catch (e) {
          throw RestApiException(
            url: url,
            statusCode: response.statusCode,
            message: 'API returned invalid question data.',
            responseBodyPreview: e.toString(),
          );
        }
      }

      final preview = _previewBody(response.body);
      throw RestApiException(
        url: url,
        statusCode: response.statusCode,
        message: 'API returned a non-success response.',
        responseBodyPreview: preview,
      );
    } catch (e) {
      if (e is RestApiException) rethrow;
      throw RestApiException(
        url: url,
        message: 'Could not reach REST API.',
        responseBodyPreview: e.toString(),
      );
    }
  }

  List<dynamic> _extractQuestionList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = <dynamic>[
        decoded['data'],
        decoded['items'],
        decoded['questions'],
      ];

      for (final candidate in candidates) {
        if (candidate is List<dynamic>) {
          return candidate;
        }
      }
    }

    return <dynamic>[];
  }

  String? _previewBody(String? body) {
    final content = (body ?? '').toString();
    if (content.trim().isEmpty) return null;
    return content.length > 1000 ? '${content.substring(0, 1000)}...' : content;
  }
}
