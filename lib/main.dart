import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfig = SupabaseConfig.fromEnvironment();

  await Supabase.initialize(
    url: supabaseConfig.url.toString(),
    publishableKey: supabaseConfig.publishableKey,
  );

  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [themePreferencesProvider.overrideWithValue(preferences)],
      child: const PastPapersApp(),
    ),
  );
}
