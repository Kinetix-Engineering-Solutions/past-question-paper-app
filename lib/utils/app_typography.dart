import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// PQP Typography: Montserrat for headings/titles, Inter for body/labels.
class AppTypography {
  static TextTheme textTheme([TextTheme? seed]) {
    final seedTheme = seed ?? ThemeData.light().textTheme;
    final mont = GoogleFonts.montserratTextTheme(seedTheme);
    final inter = GoogleFonts.interTextTheme(seedTheme);
    // Slightly reduce overall font sizes for a tighter, denser UI.
    const fontScale = 0.94;

    final composed = TextTheme(
      // Headings & titles (Montserrat)
      headlineLarge: mont.headlineLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      headlineMedium: mont.headlineMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineSmall: mont.headlineSmall?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: mont.titleLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: mont.titleMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: mont.titleSmall?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
      ),

      // Body & labels (Inter)
      bodyLarge: inter.bodyLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: AppColors.neutralSoft,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        color: AppColors.neutralMid,
        letterSpacing: 0.2,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        color: AppColors.neutralSoft,
        letterSpacing: 0.3,
      ),
    );

    TextStyle? scale(TextStyle? s) =>
        (s == null || s.fontSize == null)
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
