import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:past_question_paper_v1/core/shared/models/rest_api_question.dart';

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
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final queryParameters = <String, String>{
      'subject': _toApiSubject(subject),
      'grade': grade.toString(),
      'topic': topic.trim(),
      if (startYear != null) 'startYear': startYear.toString(),
      if (endYear != null) 'endYear': endYear.toString(),
      if (paper != null && paper.trim().isNotEmpty) 'paper': paper.trim(),
      if (season != null && season.trim().isNotEmpty) 'season': season.trim(),
      if (questionNumber != null && questionNumber.trim().isNotEmpty)
        'questionNumber': questionNumber.trim(),
      if (questionPrefix != null && questionPrefix.trim().isNotEmpty)
        'questionPrefix': questionPrefix.trim(),
    };

    final url = Uri.parse(
      '$_baseUrl/api/questions',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client.get(url).timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = _extractQuestionList(decoded);
        return list
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .map(RestApiQuestion.fromJson)
            .toList();
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

  String _toApiSubject(String value) {
    final normalized = value.trim().toLowerCase();
    // Backend expects full subject name (e.g. "mathematics"), not "math".
    if (normalized == 'math') return 'mathematics';
    if (normalized == 'maths') return 'mathematics';
    return normalized;
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
