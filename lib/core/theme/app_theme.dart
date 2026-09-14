import 'package:flutter/material.dart';

abstract final class AppColors {
  // Neutral paper foundation
  static const ink = Color(0xFF0F2340);
  static const mutedInk = Color(0xFF5F6877);

  static const paper = Color(0xFFFFFDF8);
  static const neutralCard = Color(0xFFFFFFFF);
  static const border = Color(0xFFE4E7EC);
  static const softBlue = Color(0xFFDDE7FA);
  static const iconTile = Color(0xFFE8EEF7);
  static const topicIcon = Color(0xFF31507A);
  static const softGreen = Color(0xFFE6F3EA);

  // Logo colours
  static const brandCyan = Color(0xFF29A9DC);
  static const brandPink = Color(0xFFED0A8C);
  static const brandPeriwinkle = Color(0xFF7391CF);

  // Navy primary actions and blue accents
  static const primary = Color(0xFF0F2340);
  static const secondary = Color(0xFF3157B3);

  // Semantic colours
  static const success = Color(0xFF34A66F);
  static const error = Color(0xFFBA1A1A);
}

class AppPalette {
  const AppPalette(this.isDark);

  final bool isDark;
  static AppPalette of(BuildContext context) =>
      AppPalette(Theme.of(context).brightness == Brightness.dark);

  Color get ink => isDark ? const Color(0xFFE8E8E8) : AppColors.ink;
  Color get mutedInk => isDark ? const Color(0xFFA3A3A3) : AppColors.mutedInk;
  Color get paper => isDark ? const Color(0xFF121212) : AppColors.paper;
  Color get neutralCard =>
      isDark ? const Color(0xFF1E1E1E) : AppColors.neutralCard;
  Color get border => isDark ? const Color(0xFF333333) : AppColors.border;
  Color get softBlue => isDark ? const Color(0xFF292929) : AppColors.softBlue;
  Color get iconTile => isDark ? const Color(0xFF292929) : AppColors.iconTile;
  Color get topicIcon => isDark ? const Color(0xFFE8E8E8) : AppColors.topicIcon;
  Color get softGreen => isDark ? const Color(0xFF25332A) : AppColors.softGreen;
  Color get primary => isDark ? const Color(0xFFE8E8E8) : AppColors.primary;
  Color get onPrimary => isDark ? const Color(0xFF121212) : Colors.white;
  Color get secondary => isDark ? const Color(0xFFE8E8E8) : AppColors.secondary;
  Color get success => isDark ? const Color(0xFF75A88B) : AppColors.success;
  Color get error => isDark ? const Color(0xFFFFB4AB) : AppColors.error;
}

abstract final class AppTheme {
  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);

  static ThemeData _build(bool isDark) {
    final colors = AppPalette(isDark);
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.softBlue,
      onPrimaryContainer: colors.ink,
      secondary: colors.secondary,
      onSecondary: colors.onPrimary,
      secondaryContainer: colors.softBlue,
      onSecondaryContainer: colors.ink,
      tertiary: colors.success,
      onTertiary: isDark ? const Color(0xFF121212) : AppColors.primary,
      tertiaryContainer: colors.softGreen,
      onTertiaryContainer: colors.ink,
      error: colors.error,
      onError: isDark ? const Color(0xFF121212) : Colors.white,
      surface: colors.neutralCard,
      surfaceContainerLowest: colors.paper,
      surfaceContainerLow: colors.neutralCard,
      surfaceContainer: colors.neutralCard,
      surfaceContainerHigh: isDark ? colors.softBlue : colors.neutralCard,
      surfaceContainerHighest: isDark ? colors.border : colors.softBlue,
      onSurface: colors.ink,
      onSurfaceVariant: colors.mutedInk,
      outline: colors.border,
      outlineVariant: colors.border,
    );

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 35,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      displayMedium: TextStyle(
        fontSize: 31,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      headlineLarge: TextStyle(
        fontSize: 25,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 21,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 19,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colors.mutedInk,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colors.mutedInk,
      ),
      bodySmall: TextStyle(
        fontSize: 10,
        height: 1.4,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colors.mutedInk,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      labelMedium: TextStyle(
        fontSize: 10,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colors.ink,
      ),
      labelSmall: TextStyle(
        fontSize: 9,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colors.mutedInk,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.paper,
      fontFamily: 'Inter',

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.paper,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.ink,
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.neutralCard,
        elevation: 3,
        shadowColor: (isDark ? Colors.black : colors.ink).withValues(
          alpha: 0.18,
        ),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark ? BorderSide(color: colors.border) : BorderSide.none,
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colors.ink,
        textColor: colors.ink,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: colors.ink),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.neutralCard,
        labelStyle: TextStyle(color: colors.mutedInk, letterSpacing: 0.5),
        hintStyle: TextStyle(color: colors.mutedInk, letterSpacing: 0.5),
        prefixIconColor: colors.mutedInk,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.border,
          disabledForegroundColor: colors.mutedInk,
          minimumSize: Size(48, 52),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: Size(48, 52),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.success,
        linearTrackColor: colors.softGreen,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.neutralCard,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colors.border,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.neutralCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.border : colors.ink,
        contentTextStyle: TextStyle(color: Colors.white, letterSpacing: 0.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
