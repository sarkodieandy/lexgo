import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandBlue).copyWith(
      primary: AppColors.brandBlue,
      onPrimary: AppColors.brandWhite,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.brandDark,
      displayColor: AppColors.brandDark,
    ),
  );
}
