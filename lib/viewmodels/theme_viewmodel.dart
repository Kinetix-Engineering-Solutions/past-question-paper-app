import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';

@immutable
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.isLoaded,
  });

  final ThemeMode mode;
  final bool isLoaded;

  ThemeState copyWith({ThemeMode? mode, bool? isLoaded}) {
    return ThemeState(
      mode: mode ?? this.mode,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class ThemeViewModel extends StateNotifier<ThemeState> {
  ThemeViewModel() : super(const ThemeState(mode: ThemeMode.system, isLoaded: false)) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(_themeModeKey);

    if (storedValue == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final mode = _mapStringToThemeMode(storedValue);
    state = state.copyWith(mode: mode, isLoaded: true);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode, isLoaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _mapThemeModeToString(mode));
  }

  Future<void> toggleLightDark() async {
    final current = state.mode;
    switch (current) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.dark);
        break;
    }
  }

  ThemeMode _mapStringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _mapThemeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeViewModelProvider =
    StateNotifierProvider<ThemeViewModel, ThemeState>((ref) {
  return ThemeViewModel();
});
