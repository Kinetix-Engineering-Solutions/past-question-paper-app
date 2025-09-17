import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/firebase_options.dart';
import 'package:past_question_paper_v1/services/deep_link_handler.dart';
import 'package:past_question_paper_v1/services/navigation_service.dart';
import 'package:past_question_paper_v1/utils/app_theme.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/views/login.dart';
import 'package:past_question_paper_v1/views/main_navigation_screen.dart';
import 'package:past_question_paper_v1/views/onboarding_screen.dart';
import 'package:past_question_paper_v1/views/signup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load dotenv from a specific path before anything else
  await dotenv.load(fileName: '.env');

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(dotenv.env['RECAPTCHA_V3_SITE_KEY'] ?? ''),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'STEM Question Papers',
      navigatorKey: NavigationService.navigatorKey,
      theme: AppTheme.paperAndInkTheme,
      home: const AppInitializer(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    final authService = ref.read(authViewModelProvider.notifier).authService;
    final deepLinkHandler = DeepLinkHandler(authService, context: context);
    await deepLinkHandler.handleIncomingLinks();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        } else if (user.hasCompletedProfile) {
          return const MainNavigationScreen();
        } else {
          return const OnboardingScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      error: (error, stack) {
        return const LoginScreen();
      },
    );
  }
}
