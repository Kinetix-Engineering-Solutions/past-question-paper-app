import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get paperAndInkTheme => lightTheme;

  static ThemeData get lightTheme => _buildTheme(
    const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.neutralCard,
      secondary: AppColors.ink,
      onSecondary: AppColors.neutralCard,
      surface: AppColors.neutralCard,
      onSurface: AppColors.ink,
      background: AppColors.paper,
      onBackground: AppColors.ink,
      error: AppColors.ink,
      onError: AppColors.neutralCard,
      outline: AppColors.neutralBorder,
      outlineVariant: AppColors.neutralMid,
    ),
  );

  static ThemeData get darkTheme => _buildTheme(
    const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColorsDark.paper,
      secondary: AppColorsDark.ink,
      onSecondary: AppColorsDark.paper,
      surface: AppColorsDark.neutralCard,
      onSurface: AppColorsDark.ink,
      background: AppColorsDark.paper,
      onBackground: AppColorsDark.ink,
      error: AppColorsDark.ink,
      onError: AppColorsDark.paper,
      outline: AppColorsDark.neutralBorder,
      outlineVariant: AppColorsDark.neutralSoft,
    ),
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final accent = AppColors.accent;
    final accentSoft = isDark ? AppColorsDark.accentSoft : AppColors.accentSoft;
    final paper = isDark ? AppColorsDark.paper : AppColors.paper;
    final ink = isDark ? AppColorsDark.ink : AppColors.ink;
    final neutralMid = isDark ? AppColorsDark.neutralMid : AppColors.neutralMid;
    final neutralSoft = isDark
        ? AppColorsDark.neutralSoft
        : AppColors.neutralSoft;
    final neutralCard = isDark
        ? AppColorsDark.neutralCard
        : AppColors.neutralCard;
    final neutralBorder = isDark
        ? AppColorsDark.neutralBorder
        : AppColors.neutralBorder;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      textTheme: AppTypography.textTheme(null, isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: ink, size: 24),
      ),
      cardTheme: CardThemeData(
        color: neutralCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          overlayColor: Colors.white.withOpacity(0.1),
          side: BorderSide.none, // No outline
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
          foregroundColor: accent,
          overlayColor: accent.withOpacity(0.08),
          side: BorderSide.none, // No outline
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
          foregroundColor: accent,
          side: BorderSide(
            color: neutralBorder,
            width: 1,
          ), // Subtle neutral border only
          overlayColor: accent.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColorsDark.neutralCard : paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: neutralBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: neutralBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ink, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ink),
        ),
        labelStyle: TextStyle(color: neutralMid),
        hintStyle: TextStyle(color: neutralSoft),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentSoft,
        deleteIconColor: accent,
        labelStyle: TextStyle(
          color: ink,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: accent),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: neutralBorder,
        thickness: 0.5,
        space: 1,
      ),
      iconTheme: IconThemeData(color: ink, size: 24),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColorsDark.neutralCard : AppColors.ink,
        selectedItemColor: accent,
        unselectedItemColor: neutralSoft,
        selectedIconTheme: IconThemeData(color: accent, size: 24),
        unselectedIconTheme: IconThemeData(color: neutralSoft, size: 22),
        selectedLabelStyle: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          color: neutralSoft,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        enableFeedback: true,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: neutralCard,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      splashColor: ink.withOpacity(isDark ? 0.15 : 0.08),
      highlightColor: neutralMid.withOpacity(isDark ? 0.25 : 0.15),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: accentSoft,
        thumbColor: accent,
        overlayColor: const Color(0x33FF7A1A),
        valueIndicatorColor: accent,
        trackHeight: 4,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: accentSoft,
        circularTrackColor: accentSoft,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        splashColor: const Color(0x33FF7A1A),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) =>
              states.contains(MaterialState.selected) ? accent : neutralSoft,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? accent.withOpacity(0.6)
              : neutralBorder,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) =>
              states.contains(MaterialState.selected) ? accent : neutralBorder,
        ),
        checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: neutralMid, width: 1),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) =>
              states.contains(MaterialState.selected) ? accent : neutralMid,
        ),
      ),
    );
  }
}
