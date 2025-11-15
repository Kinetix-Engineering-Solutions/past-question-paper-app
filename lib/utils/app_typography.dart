import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// PQP Typography: Poppins across the entire interface for a unified voice.
class AppTypography {
  static TextTheme textTheme([TextTheme? seed, bool isDark = false]) {
    final seedTheme = seed ?? ThemeData.light().textTheme;
    final poppins = GoogleFonts.poppinsTextTheme(seedTheme);
    // Slightly reduce overall font sizes for a tighter, denser UI.
    const fontScale = 0.94;

    // Select colors based on theme brightness
    final ink = isDark ? AppColorsDark.ink : AppColors.ink;
    final neutralMid = isDark ? AppColorsDark.neutralMid : AppColors.neutralMid;
    final neutralSoft = isDark
        ? AppColorsDark.neutralSoft
        : AppColors.neutralSoft;

    final composed = TextTheme(
      // Headings & titles (Poppins)
      headlineLarge: poppins.headlineLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      headlineMedium: poppins.headlineMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineSmall: poppins.headlineSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: poppins.titleLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: poppins.titleMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: poppins.titleSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),

      // Body & labels (Poppins for consistency)
      bodyLarge: poppins.bodyLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: poppins.bodyMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: poppins.bodySmall?.copyWith(
        color: neutralSoft,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: poppins.labelLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: poppins.labelMedium?.copyWith(
        color: neutralMid,
        letterSpacing: 0.2,
      ),
      labelSmall: poppins.labelSmall?.copyWith(
        color: neutralSoft,
        letterSpacing: 0.3,
      ),
    );

    TextStyle? scale(TextStyle? s) => (s == null || s.fontSize == null)
        ? s
        : s.copyWith(fontSize: s.fontSize! * fontScale);

    return composed.copyWith(
      headlineLarge: scale(composed.headlineLarge),
      headlineMedium: scale(composed.headlineMedium),
      headlineSmall: scale(composed.headlineSmall),
      titleLarge: scale(composed.titleLarge),
      titleMedium: scale(composed.titleMedium),
      titleSmall: scale(composed.titleSmall),
      bodyLarge: scale(composed.bodyLarge),
      bodyMedium: scale(composed.bodyMedium),
      bodySmall: scale(composed.bodySmall),
      labelLarge: scale(composed.labelLarge),
      labelMedium: scale(composed.labelMedium),
      labelSmall: scale(composed.labelSmall),
    );
  }
}
