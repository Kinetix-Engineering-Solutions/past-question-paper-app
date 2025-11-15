import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/services/connectivity_service.dart';

/// Global singleton instance of ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  
  // Ensure cleanup when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Stream provider for connectivity status
/// 
/// Widgets can watch this provider to reactively update UI based on
/// network connectivity changes.
/// 
/// Example usage:
/// ```dart
/// final connectivityStatus = ref.watch(connectivityStatusProvider);
/// connectivityStatus.when(
///   data: (status) {
///     if (status == ConnectivityStatus.offline) {
///       // Show offline UI
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Provider for synchronous access to current connectivity status
/// 
/// Useful when you need immediate status without watching the stream.
/// 
/// Example:
/// ```dart
/// final status = ref.read(currentConnectivityStatusProvider);
/// if (status == ConnectivityStatus.offline) {
///   // Don't attempt network call
///   return;
/// }
/// ```
final currentConnectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.currentStatus;
});

/// Helper method to manually trigger connectivity recheck
/// 
/// Useful for "Retry" buttons in offline states.
/// 
/// Example:
/// ```dart
/// ElevatedButton(
///   onPressed: () => ref.read(connectivityServiceProvider).recheckConnectivity(),
///   child: Text('Retry'),
/// )
/// ```
extension ConnectivityProviderExtensions on WidgetRef {
  Future<void> recheckConnectivity() async {
    await read(connectivityServiceProvider).recheckConnectivity();
  }
}
