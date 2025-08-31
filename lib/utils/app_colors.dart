import 'package:flutter/material.dart';

/// PQP brand color palette (minimal monochrome + orange accent).
class AppColors {
  // Two-color grayscale scheme selection:
  // ink (primary/dark) & paper (background/light)
  static const Color ink = Color(
    0xFF262626,
  ); // lighter charcoal for text & primary
  static const Color paper = Color(0xFFF5F5F5); // light gray background

  // Supporting derived neutrals (still within grayscale, not new "colors")
  static const Color neutralMid = Color(
    0xFF5A5A5A,
  ); // secondary text / borders (adjusted for new ink)
  static const Color neutralSoft = Color(
    0xFF8C8C8C,
  ); // tertiary text (adjusted)
  static const Color neutralCard = Color(0xFFFFFFFF); // pure white cards
  static const Color neutralBorder = Color(0xFFDDDDDD); // light border

  // Accent orange (single chromatic color in otherwise monochrome palette)
  static const Color accent = Color(0xFFFF7A1A); // primary action / highlight
  static const Color accentSoft = Color(
    0xFFFFF4EB,
  ); // very light tint background

  // Removed legacy multi-color aliases (cleanup).
  // 'chalkWhite' retained as an alias to 'paper' for backwards compatibility.
  static const Color chalkWhite = paper;
}

/// Extension to provide semantic color access
extension AppColorsExtension on ColorScheme {
  // Practice mode tones
  Color get quickPracticeColor => AppColors.neutralMid;
  Color get standardPracticeColor => AppColors.ink;
  Color get extendedPracticeColor => AppColors.neutralSoft;
  Color get unlimitedPracticeColor => AppColors.ink;

  // Semantic colors
  Color get successColor => AppColors.ink;
  Color get warningColor => AppColors.neutralMid; // monochrome warning
  Color get paperBackground => AppColors.paper;
  Color get cardBackground => AppColors.neutralCard;
  Color get textSecondary => AppColors.neutralMid;
  Color get borderColor => AppColors.neutralBorder;

  // Orange accent for highlights
  Color get accentOrange => AppColors.accent;

  // Chalkboard-like tones
  Color get chalkboardBackground => AppColors.ink;
  Color get chalkColor => AppColors.neutralCard;
}

/// Gradient utilities updated to new brand palette
class PQPGradients {
  // Subtle gradient (card to paper)
  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.neutralCard, AppColors.paper],
  );

  // Classic neutral gradient (paper to ink)
  static const LinearGradient classic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.paper, AppColors.ink],
  );

  // Deep gradient (mid to ink)
  static const LinearGradient deep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.neutralMid, AppColors.ink],
  );

  // Full spectrum gradient (paper -> card -> mid -> ink)
  static const LinearGradient spectrum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.paper,
      AppColors.neutralCard,
      AppColors.neutralMid,
      AppColors.ink,
    ],
    stops: [0.0, 0.25, 0.6, 1.0],
  );

  // Diagonal gradient (mid to ink)
  static const LinearGradient diagonal = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.neutralMid, AppColors.ink],
  );

  // Vertical gradient (paper to ink)
  static const LinearGradient vertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.paper, AppColors.ink],
  );
}


