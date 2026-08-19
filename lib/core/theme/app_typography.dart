import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:past_question_paper_v1/core/theme/app_colors.dart';

/// PQP Typography: Manrope across the entire interface as the global typeface.
class AppTypography {
  static TextTheme textTheme([TextTheme? seed, bool isDark = false]) {
    final seedTheme = seed ?? ThemeData.light().textTheme;
    final baseTypography = GoogleFonts.poppinsTextTheme(seedTheme);
    // Slightly reduce overall font sizes for a tighter, denser UI.
    const fontScale = 0.80;

    // Select colors based on theme brightness
    final ink = isDark ? AppColorsDark.ink : AppColors.ink;
    final neutralMid = isDark ? AppColorsDark.neutralMid : AppColors.neutralMid;
    final neutralSoft = isDark
        ? AppColorsDark.neutralSoft
        : AppColors.neutralSoft;

    final composed = TextTheme(
      // Headings & titles (Manrope)
      headlineLarge: baseTypography.headlineLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      headlineMedium: baseTypography.headlineMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineSmall: baseTypography.headlineSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: baseTypography.titleLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTypography.titleMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTypography.titleSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),

      // Body & labels (Manrope for consistency)
      bodyLarge: baseTypography.bodyLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: baseTypography.bodyMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: baseTypography.bodySmall?.copyWith(
        color: neutralSoft,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: baseTypography.labelLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: baseTypography.labelMedium?.copyWith(
        color: neutralMid,
        letterSpacing: 0.2,
      ),
      labelSmall: baseTypography.labelSmall?.copyWith(
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
