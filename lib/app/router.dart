import 'package:go_router/go_router.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';
import 'package:past_question_paper_v1/features/quiz/quiz_home_screen.dart';
import 'package:past_question_paper_v1/features/results/history.dart';
import 'package:past_question_paper_v1/features/results/quiz_results.dart';
import 'package:past_question_paper_v1/features/results/review_answers.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import 'package:past_question_paper_v1/features/settings/settings.dart';
import 'package:past_question_paper_v1/features/quiz/quiz_flow_screen.dart';
import '../features/auth/onboarding.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/subject_selection.dart';
import '../features/home/dashboard.dart';
import '../features/profile/user_profile.dart';
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
        path: '/helperAndsupport',
        name: 'helperAndsupport',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const DashboardPage(),
      ),

      // ✅ Only one quizSession route should exist
      GoRoute(
        path: '/quizsession',
        name: 'quizSession',
        builder: (context, state) {
          final subjectId = state.uri.queryParameters['subjectId'] ?? '';
          final subjectName = state.uri.queryParameters['subjectName'] ?? '';
          final gradeId = state.uri.queryParameters['gradeId'] ?? '';
          final gradeName = state.uri.queryParameters['gradeName'] ?? '';

          return QuizHomeScreen(
            subjectId: subjectId,
            subjectName: subjectName,
            gradeId: gradeId,
            gradeName: gradeName,
          );
        },
      ),
      GoRoute(path: '/result', builder: (context, state) => const ResultPage()),

      GoRoute(
        path: '/answers',
        name: 'answers',
        builder: (context, state) => const ReviewAnswersPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const QuizHistoryPage(),
      ),

      // ✅ Fixed Quiz flow route
      GoRoute(
        path: '/quiz-flow',
        name: 'quizFlow',
        builder: (context, state) {
          final subjectId = state.uri.queryParameters['subjectId'] ?? '';
          final subjectName = state.uri.queryParameters['subjectName'] ?? '';
          final gradeId = state.uri.queryParameters['gradeId'] ?? '';
          final gradeName = state.uri.queryParameters['gradeName'] ?? '';
          final quizTypeStr = state.uri.queryParameters['quizType'] ?? '';

          QuizType quizType;
          try {
            quizType = QuizType.values.firstWhere(
              (e) => e.toString().split('.').last == quizTypeStr,
            );
          } catch (e) {
            quizType = QuizType.multipleChoice; // fallback
          }

          return QuizFlowScreen(
            subjectId: subjectId,
            subjectName: subjectName,
            gradeId: gradeId,
            gradeName: gradeName,
            quizType: quizType,
          );
        },
      ),
    ],
  );
}
