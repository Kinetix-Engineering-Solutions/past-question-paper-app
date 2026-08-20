import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_client.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUri: ref.watch(appConfigProvider).contentApiBaseUri,
    httpClient: ref.watch(httpClientProvider),
  );
});
