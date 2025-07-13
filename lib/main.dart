import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/firebase_options.dart';
import 'package:past_question_paper_stem/services/deep_link_handler.dart';
import 'package:past_question_paper_stem/services/navigation_service.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_stem/views/login.dart';
import 'package:past_question_paper_stem/views/signup_screen.dart';
import 'package:past_question_paper_stem/views/main_navigation_screen.dart';
import 'package:past_question_paper_stem/views/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'STEM Question Papers',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
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
      loading:
          () => const Scaffold(
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
