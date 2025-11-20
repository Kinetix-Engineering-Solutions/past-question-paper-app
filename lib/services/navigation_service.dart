import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/views/main_navigation_screen.dart';
import 'package:past_question_paper_v1/views/login.dart';
import 'package:past_question_paper_v1/views/onboarding_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to home screen and clear all previous routes
  static Future<void> navigateToHome() async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    await nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  /// Navigate to onboarding screen and clear all previous routes
  static Future<void> navigateToOnboarding() async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    await nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  /// Navigate to login screen and clear all previous routes
  static Future<void> navigateToLogin() async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    await nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  /// Navigate to a specific screen with replacement
  static Future<void> navigateToWithReplacement(Widget screen) async {
    if (context == null) return;

    await Navigator.of(
      context!,
    ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  /// Navigate to a specific screen with push
  static Future<void> navigateTo(Widget screen) async {
    if (context == null) return;

    await Navigator.of(
      context!,
    ).push(MaterialPageRoute(builder: (context) => screen));
  }

  /// Navigate back if possible
  static void navigateBack() {
    if (context == null) return;

    if (Navigator.of(context!).canPop()) {
      Navigator.of(context!).pop();
    }
  }

  /// Navigate back to a specific route
  static void navigateBackTo(String routeName) {
    if (context == null) return;

    Navigator.of(context!).popUntil(ModalRoute.withName(routeName));
  }

  /// Clear all routes and navigate to a new screen
  static Future<void> navigateAndClearStack(Widget screen) async {
    if (context == null) return;

    await Navigator.of(context!).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  /// Show a modal bottom sheet
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    if (context == null) return null;

    return await showModalBottomSheet<T>(
      context: context!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => child,
    );
  }

  /// Show a dialog
  static Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    if (context == null) return null;

    return await showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }
}
