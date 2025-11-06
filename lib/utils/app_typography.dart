import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// PQP Typography: Poppins for headings/titles, Inter for body/labels.
class AppTypography {
  static TextTheme textTheme([TextTheme? seed, bool isDark = false]) {
    final seedTheme = seed ?? ThemeData.light().textTheme;
    final poppins = GoogleFonts.poppinsTextTheme(seedTheme);
    final inter = GoogleFonts.interTextTheme(seedTheme);
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

      // Body & labels (Inter)
      bodyLarge: inter.bodyLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: neutralSoft,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        color: neutralMid,
        letterSpacing: 0.2,
      ),
      labelSmall: inter.labelSmall?.copyWith(
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
