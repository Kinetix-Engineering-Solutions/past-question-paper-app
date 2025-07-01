// lib/routes/app_router.dart
import 'package:go_router/go_router.dart';

import 'package:past_question_paper_v1/features/settings/settings.dart';
import 'package:past_question_paper_v1/quiz/quiz_flow_screen.dart';
import '../features/auth/onboarding.dart';
import '../features/auth/subject_selection.dart';
import '../features/home/dashboard.dart';
import '../features/profile/user_profile.dart';



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
    ],
  );
}
