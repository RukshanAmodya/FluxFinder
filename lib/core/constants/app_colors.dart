import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color accentCyan = Color(0xFF00F2FF);
  static const Color accentPurple = Color(0xFFC084FC);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBackground = Color(0x0DFFFFFF);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF00F2FF), Color(0xFF0061FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ghostGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
