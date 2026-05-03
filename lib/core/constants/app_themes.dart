import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.accentCyan,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentCyan,
      secondary: AppColors.accentPurple,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w200, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w200, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w300, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w300, color: AppColors.textSecondary),
    ),
    cardTheme: CardTheme(
      color: AppColors.glassBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
    ),
  );
}
