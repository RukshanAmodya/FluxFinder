import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFFBF00FF);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00B2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFBF00FF), Color(0xFF7B00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
