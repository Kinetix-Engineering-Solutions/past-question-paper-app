import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:past_question_paper_v1/firebase_options.dart';
import 'package:past_question_paper_v1/core/theme/app_theme.dart';
import 'package:past_question_paper_v1/core/shared/widgets/connectivity_banner.dart';
import 'package:past_question_paper_v1/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (e.g. Supabase config URL).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Intentionally ignore missing/invalid .env in release builds.
  }

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
    // Use the debug provider for testing in debug builds.
    // You will need to configure the reCAPTCHA v3 provider for production.
    webProvider: ReCaptchaV3Provider('debug'),
    // Set androidProvider to `AndroidProvider.debug`
    androidProvider: AndroidProvider.debug,
    // Set appleProvider to `AppleProvider.debug`
    appleProvider: AppleProvider.debug,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Past Papers Pilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
      routes: {'/home': (context) => const HomeScreen()},
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ConnectivityBanner(),
            ),
          ],
        );
      },
    );
  }
}
