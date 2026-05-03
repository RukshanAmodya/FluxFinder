import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.accentCyan,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentCyan,
      secondary: AppColors.accentPurple,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white10),
      ),
    ),
  );

  static ThemeData ghostTheme = darkTheme.copyWith(
    primaryColor: AppColors.accentPurple,
    colorScheme: darkTheme.colorScheme.copyWith(
      primary: AppColors.accentPurple,
      secondary: AppColors.accentCyan,
    ),
    scaffoldBackgroundColor: Color(0xFF100020), // Dark thermal purple
  );
}
