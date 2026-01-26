import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    textTheme: GoogleFonts.poppinsTextTheme()
        .apply(
          bodyColor: AppColors.brandDark,
          displayColor: AppColors.brandDark,
        )
        .copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            textStyle: GoogleFonts.poppins().copyWith(
              color: AppColors.brandDark,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            textStyle: GoogleFonts.poppins().copyWith(
              color: AppColors.brandDark,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          headlineSmall: GoogleFonts.playfairDisplay(
            textStyle: GoogleFonts.poppins().copyWith(
              color: AppColors.brandDark,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
  );
}
