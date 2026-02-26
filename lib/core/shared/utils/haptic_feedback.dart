import 'package:flutter/services.dart';

class AppHaptics {
  /// Light impact feedback for subtle interactions
  static void light() => HapticFeedback.lightImpact();

  /// Medium impact for standard button presses
  static void medium() => HapticFeedback.mediumImpact();

  /// Heavy impact for important actions
  static void heavy() => HapticFeedback.heavyImpact();

  /// Selection click for toggles and selections
  static void selection() => HapticFeedback.selectionClick();

  /// Success pattern - double tap
  static void success() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error pattern - strong double tap
  static void error() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.heavyImpact();
    });
  }
}
