import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.brandDark,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.brandDark,
          onPrimary: AppColors.brandWhite,
          surface: AppColors.surface,
        ),
    scaffoldBackgroundColor: AppColors.brandDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brandDark,
      foregroundColor: AppColors.brandWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandDark,
        foregroundColor: AppColors.brandWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _FadeScalePageTransitionBuilder(),
        TargetPlatform.iOS: _FadeScalePageTransitionBuilder(),
        TargetPlatform.linux: _FadeScalePageTransitionBuilder(),
        TargetPlatform.macOS: _FadeScalePageTransitionBuilder(),
        TargetPlatform.windows: _FadeScalePageTransitionBuilder(),
      },
    ),
  );
}

class _FadeScalePageTransitionBuilder extends PageTransitionsBuilder {
  const _FadeScalePageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOut,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
