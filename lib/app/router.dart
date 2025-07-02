// lib/routes/app_router.dart
import 'package:go_router/go_router.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';

import 'package:past_question_paper_v1/features/settings/settings.dart';
import 'package:past_question_paper_v1/quiz/quiz_flow_screen.dart';
import '../features/auth/onboarding.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/subject_selection.dart';
import '../features/home/dashboard.dart';
import '../features/profile/user_profile.dart';


import '../features/settings/settings.dart';
import '../features/settings/help_and_support.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        builder: (context, state) => const SubjectSelectionPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
      path: '/quiz/session',
       name: 'quiz_flow_screen',
       builder: (context, state) => const QuizFlowScreen(),
),
      GoRoute(
        path: '/helperAndsupport',
        name: 'helperAndsupport',
        builder: (context, state) => const HelpSupportScreen(),
      ),
    ],
  );
}
