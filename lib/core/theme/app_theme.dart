import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.neutralCard,
      secondary: AppColors.ink,
      onSecondary: AppColors.neutralCard,
      surface: AppColors.neutralCard,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
    );
  }
}
