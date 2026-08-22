import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfig = SupabaseConfig.fromEnvironment();

  await Supabase.initialize(
    url: supabaseConfig.url.toString(),
    publishableKey: supabaseConfig.publishableKey,
  );

  runApp(const ProviderScope(child: PastPapersApp()));
}
