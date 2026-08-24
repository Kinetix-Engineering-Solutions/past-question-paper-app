import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

final class ApiClient {
  ApiClient({
    required Uri baseUri,
    required http.Client httpClient,
    Duration timeout = const Duration(seconds: 15),
  }) : _baseUri = baseUri,
       _httpClient = httpClient,
       _timeout = timeout;

  final Uri _baseUri;
  final http.Client _httpClient;
  final Duration _timeout;

  Future<Object?> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);

    try {
      final response = await _httpClient
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          type: ApiFailureType.http,
          statusCode: response.statusCode,
          message: 'The server could not complete the request.',
        );
      }

      try {
        return jsonDecode(response.body);
      } on FormatException {
        throw const ApiException(
          type: ApiFailureType.invalidResponse,
          message: 'The server returned an invalid response.',
        );
      }
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.timeout,
        message: 'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiFailureType.network,
        message: 'Unable to connect. Check your internet connection.',
      );
    }
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalisedPath = path.startsWith('/') ? path : '/$path';

    return _baseUri.replace(
      path: normalisedPath,
      queryParameters: queryParameters,
    );
  }
}
