import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get paperAndInkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent, // orange accent for primary actions
        onPrimary: AppColors.neutralCard, // white text on accent
        secondary: AppColors.ink, // ink as secondary / emphasis
        onSecondary: AppColors.neutralCard,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        background: AppColors.paper,
        onBackground: AppColors.ink,
        error: AppColors.ink,
        onError: AppColors.neutralCard,
        outline: AppColors.neutralBorder,
        outlineVariant: AppColors.neutralMid,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.ink, size: 24),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutralCard,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: AppColors.neutralMid.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.neutralBorder, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.neutralCard,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink),
        ),
        labelStyle: const TextStyle(color: AppColors.neutralMid),
        hintStyle: const TextStyle(color: AppColors.neutralSoft),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentSoft,
        deleteIconColor: AppColors.accent,
        labelStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.accent),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutralBorder,
        thickness: 0.5,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      textTheme: AppTypography.textTheme(),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.ink,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.neutralSoft,
        selectedIconTheme: IconThemeData(color: AppColors.accent, size: 24),
        unselectedIconTheme: IconThemeData(
          color: AppColors.neutralSoft,
          size: 22,
        ),
        selectedLabelStyle: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColors.neutralSoft,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        enableFeedback: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      scaffoldBackgroundColor: AppColors.paper,
      splashColor: AppColors.ink.withOpacity(0.08),
      highlightColor: AppColors.neutralMid.withOpacity(0.15),
      // Accent components
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.accentSoft,
        thumbColor: AppColors.accent,
        overlayColor: Color(0x33FF7A1A),
        valueIndicatorColor: AppColors.accent,
        trackHeight: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.accentSoft,
        circularTrackColor: AppColors.accentSoft,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.neutralCard,
        elevation: 2,
        splashColor: Color(0x33FF7A1A),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.accent
              : AppColors.neutralSoft,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.accent.withOpacity(0.6)
              : AppColors.neutralBorder,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.accent
              : AppColors.neutralBorder,
        ),
        checkColor: MaterialStateProperty.all(AppColors.neutralCard),
        side: const BorderSide(color: AppColors.neutralMid, width: 1),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.accent
              : AppColors.neutralMid,
        ),
      ),
    );
  }
}
