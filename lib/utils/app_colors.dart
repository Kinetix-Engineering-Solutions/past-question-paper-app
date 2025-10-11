import 'package:flutter/material.dart';

/// PQP brand color palette (minimal monochrome + orange accent).
class AppColors {
  // Two-color grayscale scheme selection:
  // ink (primary/dark) & paper (background/light)
  static const Color ink = Color(
    0xFF262626,
  ); // lighter charcoal for text & primary
  static const Color paper = Color(
    0xFFF0F0ED,
  ); // warm off-white background (softer than pure gray)

  // Supporting derived neutrals (still within grayscale, not new "colors")
  static const Color neutralMid = Color(
    0xFF5A5A5A,
  ); // secondary text / borders (adjusted for new ink)
  static const Color neutralSoft = Color(
    0xFF8C8C8C,
  ); // tertiary text (adjusted)
  static const Color neutralCard = Color(
    0xFFFAFAF8,
  ); // soft cream cards (clear contrast from background)
  static const Color neutralBorder = Color(0xFFE0E0DD); // subtle warm border

  // Accent orange (single chromatic color in otherwise monochrome palette)
  static const Color accent = Color(0xFFFF7A1A); // primary action / highlight
  static const Color accentSoft = Color(
    0xFFFFF4EB,
  ); // very light tint background

  // Logo accent palette (used sparingly for illustrations & special moments)
  static const Color brandCharcoal = Color(
    0xFF101010,
  ); // logo backdrop / immersive modals
  static const Color brandCyan = Color(0xFF00A8FF); // question mark highlight
  static const Color brandMagenta = Color(0xFFFF2D9B); // playful q glyph
  static const Color brandLavender = Color(
    0xFF7F7BFF,
  ); // p glyph & supportive accents
  static const Color brandTeal = Color(
    0xFF00BBD6,
  ); // geometric nose / subtle cues

  // Removed legacy multi-color aliases (cleanup).
  // 'chalkWhite' retained as an alias to 'paper' for backwards compatibility.
  static const Color chalkWhite = paper;
}

/// Dark palette counterpart for Paper & Ink theme.
class AppColorsDark {
  static const Color ink = Color(
    0xFFF0F0F0,
  ); // Brightened primary text for better readability
  static const Color paper = Color(
    0xFF1A1A1A,
  ); // Lightened from 0F0F0F to reduce harshness

  static const Color neutralMid = Color(
    0xFFB8B8B8,
  ); // Brightened secondary text
  static const Color neutralSoft = Color(
    0xFF8C8C8C,
  ); // Brightened tertiary text
  static const Color neutralCard = Color(
    0xFF242424,
  ); // Lightened from 1E1E1E for better contrast
  static const Color neutralBorder = Color(0xFF3A3A3A); // Lightened from 2F2F2F

  static const Color accent = AppColors.accent;
  static const Color accentSoft = Color(0xFF40230F);

  static const Color brandCharcoal = AppColors.brandCharcoal;
  static const Color brandCyan = AppColors.brandCyan;
  static const Color brandMagenta = AppColors.brandMagenta;
  static const Color brandLavender = AppColors.brandLavender;
  static const Color brandTeal = AppColors.brandTeal;

  static const Color chalkWhite = ink;
}

/// Extension to provide semantic color access
extension AppColorsExtension on ColorScheme {
  // Practice mode tones
  Color get quickPracticeColor => brightness == Brightness.dark
      ? AppColorsDark.neutralMid
      : AppColors.neutralMid;
  Color get standardPracticeColor =>
      brightness == Brightness.dark ? AppColorsDark.ink : AppColors.ink;
  Color get extendedPracticeColor => brightness == Brightness.dark
      ? AppColorsDark.neutralSoft
      : AppColors.neutralSoft;
  Color get unlimitedPracticeColor =>
      brightness == Brightness.dark ? AppColorsDark.ink : AppColors.ink;

  // Semantic colors
  Color get successColor =>
      brightness == Brightness.dark ? AppColorsDark.ink : AppColors.ink;
  Color get warningColor => brightness == Brightness.dark
      ? AppColorsDark.neutralMid
      : AppColors.neutralMid; // monochrome warning
  Color get paperBackground =>
      brightness == Brightness.dark ? AppColorsDark.paper : AppColors.paper;
  Color get cardBackground => brightness == Brightness.dark
      ? AppColorsDark.neutralCard
      : AppColors.neutralCard;
  Color get textSecondary => brightness == Brightness.dark
      ? AppColorsDark.neutralMid
      : AppColors.neutralMid;
  Color get borderColor => brightness == Brightness.dark
      ? AppColorsDark.neutralBorder
      : AppColors.neutralBorder;

  // Orange accent for highlights
  Color get accentOrange => AppColors.accent;

  // Chalkboard-like tones
  Color get chalkboardBackground =>
      brightness == Brightness.dark ? AppColorsDark.paper : AppColors.ink;
  Color get chalkColor => brightness == Brightness.dark
      ? AppColorsDark.chalkWhite
      : AppColors.neutralCard;
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
