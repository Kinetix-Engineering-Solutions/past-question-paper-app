import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for different view modes
enum ViewMode {
  carousel3D, // Neural network 3D carousel view
  list, // Traditional list/card view
}

/// State for view mode preferences
class ViewModeState {
  final ViewMode homeViewMode;
  final ViewMode testConfigViewMode;

  const ViewModeState({
    this.homeViewMode = ViewMode.carousel3D,
    this.testConfigViewMode = ViewMode.carousel3D,
  });

  ViewModeState copyWith({
    ViewMode? homeViewMode,
    ViewMode? testConfigViewMode,
  }) {
    return ViewModeState(
      homeViewMode: homeViewMode ?? this.homeViewMode,
      testConfigViewMode: testConfigViewMode ?? this.testConfigViewMode,
    );
  }
}

/// ViewModel for managing view mode preferences
class ViewModeViewModel extends StateNotifier<ViewModeState> {
  static const String _homeViewModeKey = 'home_view_mode';
  static const String _testConfigViewModeKey = 'test_config_view_mode';

  ViewModeViewModel() : super(const ViewModeState()) {
    _loadViewModes();
  }

  /// Load saved view modes from SharedPreferences
  Future<void> _loadViewModes() async {
    final prefs = await SharedPreferences.getInstance();

    final homeMode = prefs.getString(_homeViewModeKey);
    final testConfigMode = prefs.getString(_testConfigViewModeKey);

    state = ViewModeState(
      homeViewMode: _parseViewMode(homeMode) ?? ViewMode.carousel3D,
      testConfigViewMode: _parseViewMode(testConfigMode) ?? ViewMode.carousel3D,
    );
  }

  /// Toggle home screen view mode
  Future<void> toggleHomeViewMode() async {
    final newMode = state.homeViewMode == ViewMode.carousel3D
        ? ViewMode.list
        : ViewMode.carousel3D;

    state = state.copyWith(homeViewMode: newMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeViewModeKey, newMode.name);
  }

  /// Toggle test configuration view mode
  Future<void> toggleTestConfigViewMode() async {
    final newMode = state.testConfigViewMode == ViewMode.carousel3D
        ? ViewMode.list
        : ViewMode.carousel3D;

    state = state.copyWith(testConfigViewMode: newMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_testConfigViewModeKey, newMode.name);
  }

  /// Set specific view mode for home screen
  Future<void> setHomeViewMode(ViewMode mode) async {
    state = state.copyWith(homeViewMode: mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeViewModeKey, mode.name);
  }

  /// Set specific view mode for test configuration
  Future<void> setTestConfigViewMode(ViewMode mode) async {
    state = state.copyWith(testConfigViewMode: mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_testConfigViewModeKey, mode.name);
  }

  /// Parse ViewMode from string
  ViewMode? _parseViewMode(String? modeString) {
    if (modeString == null) return null;

    try {
      return ViewMode.values.firstWhere((mode) => mode.name == modeString);
    } catch (e) {
      return null;
    }
  }
}

/// Provider for view mode state
final viewModeProvider =
    StateNotifierProvider<ViewModeViewModel, ViewModeState>(
      (ref) => ViewModeViewModel(),
    );
