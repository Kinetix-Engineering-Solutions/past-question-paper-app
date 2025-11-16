import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/firebase_options.dart';
import 'package:past_question_paper_v1/services/deep_link_handler.dart';
import 'package:past_question_paper_v1/services/navigation_service.dart';
import 'package:past_question_paper_v1/utils/app_theme.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/viewmodels/theme_viewmodel.dart';
import 'package:past_question_paper_v1/views/login.dart';
import 'package:past_question_paper_v1/views/main_navigation_screen.dart';
import 'package:past_question_paper_v1/views/onboarding_screen.dart';
import 'package:past_question_paper_v1/views/signup_screen.dart';
import 'package:past_question_paper_v1/views/email_verification_screen.dart';
import 'package:past_question_paper_v1/widgets/connectivity_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final themeState = ref.watch(themeViewModelProvider);

    return MaterialApp(
      title: 'STEM Question Papers',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.mode,
      home: const AppInitializer(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
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
          // User is not logged in
          return const LoginScreen();
        } else if (user.hasCompletedProfile) {
          // User is logged in and has completed profile
          return const MainNavigationScreen();
        } else {
          // User is logged in but hasn't completed profile
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
        // On error, default to login screen
        return const LoginScreen();
      },
    );
  }
}
