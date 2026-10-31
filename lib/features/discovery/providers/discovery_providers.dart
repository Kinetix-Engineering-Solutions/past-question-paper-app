import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../data/discovery_repository.dart';
import '../data/models/discovery_data.dart';

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
    final refreshed = await AsyncValue.guard(
      () => ref.read(discoveryRepositoryProvider).getGrade12Discovery(),
    );

    state = refreshed;
  }
}
