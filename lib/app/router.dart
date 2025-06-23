// routes/app_router.dart
import 'package:go_router/go_router.dart';
import '../features/auth/onboarding.dart';
import '../features/auth/subject_selection.dart';
import '../features/home/dashboard.dart';
import '../features/profile/user_profile.dart';
import '../features/settings/settings.dart';


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
    ],
  );
}
