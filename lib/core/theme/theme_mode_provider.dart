import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themePreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'Theme preferences must be initialized before starting the app.',
  );
});

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  static const preferenceKey = 'appearance.themeMode';

  @override
  ThemeMode build() {
    final saved = ref.watch(themePreferencesProvider).getString(preferenceKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    // Publish only after storage succeeds, so failures leave the setting intact.
    final stored = await ref
        .read(themePreferencesProvider)
        .setString(preferenceKey, mode.name);
    if (!stored) throw StateError('Unable to save appearance.');
    state = mode;
  }
}
