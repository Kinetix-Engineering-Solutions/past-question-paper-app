import 'package:flutter/material.dart';

/// Paper & Ink inspired color palette for academic/exam preparation app
class AppColors {
  // Primary Paper & Ink Colors
  static const Color paperWhite = Color(0xFFFAFAFA);
  static const Color inkBlack = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF2D2D2D);
  static const Color graphite = Color(0xFF6B6B6B);
  static const Color chalkboard = Color(0xFF2D5A3D); // Classic green chalkboard

  // Accent Ink Colors
  static const Color blueInk = Color(0xFF1E3A8A);
  static const Color redInk = Color(0xFFDC2626);
  static const Color greenInk = Color(0xFF059669);
  static const Color orangeInk = Color(0xFFEA580C);
  static const Color chalkWhite = Color(
    0xFFF8FAF9,
  ); // Chalk white with slight green tint

  // Surface Colors
  static const Color paperGray = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFE5E7EB);
  static const Color mediumGray = Color(0xFF9CA3AF);

  // Chalkboard Gradient Colors
  static const Color chalkboardLight = Color(
    0xFF4A7C59,
  ); // Lighter green for gradients
  static const Color chalkboardMedium = Color(0xFF3A6B47); // Medium green
  static const Color chalkboardDark = Color(
    0xFF2D5A3D,
  ); // Our main chalkboard color
  static const Color chalkboardDeep = Color(
    0xFF1E3F2A,
  ); // Deeper green for gradients

  // Practice Mode Colors (Paper & Ink themed)
  static const Color quickPracticeInk = Color(0xFF059669); // Green ink
  static const Color standardPracticeInk = Color(0xFF1E3A8A); // Blue ink
  static const Color extendedPracticeInk = Color(0xFFEA580C); // Orange ink
  static const Color unlimitedPracticeInk = Color(0xFF7C2D12); // Brown ink
}

class AppTheme {
  static ThemeData get paperAndInkTheme {
    return ThemeData(
      // Use Material 3 design system
      useMaterial3: true,

      // Color scheme based on paper and ink
      colorScheme: const ColorScheme.light(
        primary: AppColors.blueInk,
        onPrimary: AppColors.paperWhite,
        secondary: AppColors.charcoal,
        onSecondary: AppColors.paperWhite,
        surface: AppColors.paperWhite,
        onSurface: AppColors.inkBlack,
        background: AppColors.paperGray,
        onBackground: AppColors.inkBlack,
        error: AppColors.redInk,
        onError: AppColors.paperWhite,
        outline: AppColors.lightGray,
        outlineVariant: AppColors.mediumGray,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.charcoal, size: 24),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.paperWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: AppColors.lightGray.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.lightGray.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueInk,
          foregroundColor: AppColors.paperWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueInk,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.charcoal,
          side: const BorderSide(color: AppColors.lightGray),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.blueInk, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.redInk),
        ),
        labelStyle: const TextStyle(color: AppColors.graphite),
        hintStyle: const TextStyle(color: AppColors.mediumGray),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paperGray,
        deleteIconColor: AppColors.graphite,
        labelStyle: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightGray),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 0.5,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.charcoal, size: 24),

      // Text Theme (Academic/readable typography)
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
        ),

        // Titles
        titleLarge: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: AppColors.charcoal,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.0,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          color: AppColors.charcoal,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),

        // Body text
        bodyLarge: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: AppColors.charcoal,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: AppColors.graphite,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.4,
        ),

        // Labels
        labelLarge: TextStyle(
          color: AppColors.charcoal,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: AppColors.graphite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          color: AppColors.graphite,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),

      // Bottom Navigation Bar Theme (Chalkboard design)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.chalkboard,
        selectedItemColor: AppColors.chalkWhite,
        unselectedItemColor: AppColors.lightGray,
        selectedIconTheme: IconThemeData(color: AppColors.chalkWhite, size: 24),
        unselectedIconTheme: IconThemeData(
          color: AppColors.lightGray,
          size: 22,
        ),
        selectedLabelStyle: TextStyle(
          color: AppColors.chalkWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColors.lightGray,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        enableFeedback: true,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.paperWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.paperGray,

      // Splash color for ink-like effect
      splashColor: AppColors.blueInk.withOpacity(0.1),
      highlightColor: AppColors.lightGray.withOpacity(0.3),
    );
  }
}

/// Extension to provide semantic color access
extension AppColorsExtension on ColorScheme {
  // Practice mode colors
  Color get quickPracticeColor => AppColors.quickPracticeInk;
  Color get standardPracticeColor => AppColors.standardPracticeInk;
  Color get extendedPracticeColor => AppColors.extendedPracticeInk;
  Color get unlimitedPracticeColor => AppColors.unlimitedPracticeInk;

  // Semantic colors
  Color get successColor => AppColors.greenInk;
  Color get warningColor => AppColors.orangeInk;
  Color get paperBackground => AppColors.paperGray;
  Color get cardBackground => AppColors.paperWhite;
  Color get textSecondary => AppColors.graphite;
  Color get borderColor => AppColors.lightGray;

  // Chalkboard colors
  Color get chalkboardBackground => AppColors.chalkboard;
  Color get chalkColor => AppColors.chalkWhite;
}

/// Gradient utilities for chalkboard-themed cards
class ChalkboardGradients {
  // Subtle chalkboard gradient (light to medium)
  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.chalkboardLight, AppColors.chalkboardMedium],
  );

  // Classic chalkboard gradient (medium to dark)
  static const LinearGradient classic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.chalkboardMedium, AppColors.chalkboard],
  );

  // Deep chalkboard gradient (dark to deep)
  static const LinearGradient deep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.chalkboard, AppColors.chalkboardDeep],
  );

  // Full spectrum chalkboard gradient
  static const LinearGradient spectrum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.chalkboardLight,
      AppColors.chalkboardMedium,
      AppColors.chalkboard,
      AppColors.chalkboardDeep,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Diagonal chalkboard gradient
  static const LinearGradient diagonal = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.chalkboardLight, AppColors.chalkboard],
  );

  // Vertical chalkboard gradient
  static const LinearGradient vertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.chalkboardMedium, AppColors.chalkboardDeep],
  );
}
