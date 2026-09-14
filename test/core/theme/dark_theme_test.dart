import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_v1/core/theme/app_theme.dart';
import 'package:past_question_paper_v1/core/theme/theme_mode_provider.dart';
import 'package:past_question_paper_v1/shared/widgets/appearance_setting.dart';
import 'package:past_question_paper_v1/features/discovery/presentation/widgets/learner_header.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'appearance defaults to system and survives a new provider container',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [themePreferencesProvider.overrideWithValue(preferences)],
      );
      expect(container.read(themeModeProvider), ThemeMode.system);
      await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
      container.dispose();
      final restored = ProviderContainer(
        overrides: [themePreferencesProvider.overrideWithValue(preferences)],
      );
      addTearDown(restored.dispose);
      expect(restored.read(themeModeProvider), ThemeMode.dark);
    },
  );

  test('both themes have readable text and button contrast', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final scheme = theme.colorScheme;
      for (final pair in [
        (scheme.onSurface, scheme.surface),
        (scheme.onSurfaceVariant, scheme.surface),
        (scheme.onPrimary, scheme.primary),
        (scheme.onError, scheme.error),
      ]) {
        final a = pair.$1.computeLuminance();
        final b = pair.$2.computeLuminance();
        final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    }
  });

  testWidgets('system follows device and appearance switches the hero live', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themePreferencesProvider.overrideWithValue(preferences)],
        child: const _PreviewApp(),
      ),
    );
    await tester.pumpAndSettle();
    final heroContext = tester.element(find.byType(LearnerHeader));
    expect(Theme.of(heroContext).brightness, Brightness.dark);
    expect(
      Theme.of(heroContext).scaffoldBackgroundColor,
      const Color(0xFF121212),
    );
    expect(find.text('50%'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light').last);
    await tester.pumpAndSettle();
    expect(Theme.of(heroContext).brightness, Brightness.light);
    expect(preferences.getString(ThemeModeController.preferenceKey), 'light');
    expect(tester.takeException(), isNull);
  });
}

class _PreviewApp extends ConsumerWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeProvider),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 360,
            child: Column(
              children: [
                const AppearanceSetting(),
                LearnerHeader(
                  learnerName: 'Learner',
                  progress: .5,
                  reviewedQuestions: 10,
                  totalQuestions: 20,
                  isSignedIn: true,
                  onInfoPressed: () {},
                  onAccountPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
