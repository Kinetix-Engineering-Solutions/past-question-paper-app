import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Represents the current network connectivity status
enum ConnectivityStatus {
  /// Device has network connection and internet access verified
  online,
  
  /// Device has network connection but internet access unverified or slow
  degraded,
  
  /// Device has no network connection
  offline,
}

/// Service for monitoring network connectivity and internet reachability
/// 
/// Combines OS-level connectivity status with actual internet reachability
/// checks to provide accurate offline/online state for the app.
class ConnectivityService {
  ConnectivityService() {
    _initialize();
  }

  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _debounceTimer;
  Timer? _periodicCheckTimer;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  
  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  
  /// Current connectivity status (synchronous access)
  ConnectivityStatus get currentStatus => _currentStatus;

  void _initialize() {
    // Start listening to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        debugPrint('ConnectivityService error: $error');
      },
    );

    // Check initial status
    _checkConnectivity();
    
    // Periodic reachability check every 30 seconds when online
    _periodicCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Debounce rapid connectivity changes (e.g., switching between wifi/mobile)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      // If no connectivity at OS level, immediately mark offline
      if (results.contains(ConnectivityResult.none)) {
        _updateStatus(ConnectivityStatus.offline);
        return;
      }

      // OS reports connectivity, now verify actual internet reachability
      final hasInternet = await _checkInternetReachability();
      
      if (hasInternet) {
        _updateStatus(ConnectivityStatus.online);
      } else {
        // Connected to network but no internet (e.g., captive portal, DNS issues)
        _updateStatus(ConnectivityStatus.degraded);
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      // On error, assume degraded to be conservative
      _updateStatus(ConnectivityStatus.degraded);
    }
  }

  /// Check actual internet reachability with lightweight DNS lookup
  /// 
  /// Uses Google's public DNS (8.8.8.8) for fast, reliable checks.
  /// Timeout after 5 seconds to avoid blocking.
  Future<bool> _checkInternetReachability() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      debugPrint('Unexpected error in reachability check: $e');
      return false;
    }
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      debugPrint('Connectivity status changed: $newStatus');
    }
  }

  /// Manually trigger a connectivity check (useful for retry buttons)
  Future<void> recheckConnectivity() async {
    await _checkConnectivity();
  }

  /// Cleanup resources
  void dispose() {
    _debounceTimer?.cancel();
    _periodicCheckTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}
