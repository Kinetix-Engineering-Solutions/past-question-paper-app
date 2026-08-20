import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/discovery_repository.dart';
import '../data/models/discovery_data.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final httpClient = ref.watch(httpClientProvider);

  return ApiClient(baseUri: config.contentApiBaseUri, httpClient: httpClient);
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(apiClient: ref.watch(apiClientProvider));
});

final discoveryControllerProvider =
    AsyncNotifierProvider<DiscoveryController, DiscoveryData>(
      DiscoveryController.new,
    );

class DiscoveryController extends AsyncNotifier<DiscoveryData> {
  @override
  Future<DiscoveryData> build() {
    return ref.watch(discoveryRepositoryProvider).getGrade12Discovery();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(discoveryRepositoryProvider).getGrade12Discovery(),
    );
  }
}
