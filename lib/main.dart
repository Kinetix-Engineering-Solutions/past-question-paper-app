import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:past_question_paper_v1/core/theme/app_theme.dart';
import 'package:past_question_paper_v1/core/shared/widgets/connectivity_banner.dart';
import 'package:past_question_paper_v1/core/shared/services/ads_service.dart';
import 'package:past_question_paper_v1/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load public runtime configuration used by metadata and ads.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Intentionally ignore missing/invalid .env in release builds.
  }

  await AdsService.instance.initialize();

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
