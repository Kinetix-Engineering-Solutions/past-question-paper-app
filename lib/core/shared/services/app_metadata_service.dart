import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AppMetadataService {
  static const String defaultSupabaseUrl =
      'https://uaxzwifrlzlzwaltpbpf.supabase.co/storage/v1/object/public/app-config/app_metadata.sample.json';

  final http.Client _client;

  AppMetadataService({http.Client? client}) : _client = client ?? http.Client();

  Uri resolveMetadataUri({bool bustCache = false}) {
    final fromEnv = dotenv.env['APP_METADATA_URL']?.trim();
    final url = (fromEnv != null && fromEnv.isNotEmpty)
        ? fromEnv
        : defaultSupabaseUrl;

    final uri = Uri.parse(url);
    if (!bustCache) return uri;

    final updatedQuery = Map<String, String>.from(uri.queryParameters);
    updatedQuery['t'] = DateTime.now().millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: updatedQuery);
  }

  Future<String> fetchRawJson({
    Duration timeout = const Duration(seconds: 8),
    bool bustCache = false,
  }) async {
    final uri = resolveMetadataUri(bustCache: bustCache);
    final response = await _client
        .get(
          uri,
          headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
        )
        .timeout(timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw Exception('Metadata fetch failed (HTTP ${response.statusCode}).');
  }
}
