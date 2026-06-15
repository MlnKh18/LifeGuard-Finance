import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Teal / Family Focus)
  static const Color primary = Color(0xFF0F766E); // Deep Teal
  static const Color primaryLight = Color(0xFF14B8A6); // Light Teal
  static const Color primaryDark = Color(0xFF115E59); // Dark Teal
  
  // Secondary Colors (Soft Blue / Financial Trust)
  static const Color secondary = Color(0xFF0284C7); // Soft Blue
  static const Color background = Color(0xFFFAFAFA); // Clean off-white
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800 (Soft Dark)
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 (Muted Dark)
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Risk / Vulnerability Level Colors (Family-Friendly Pastel Palette)
  static const Color riskSafe = Color(0xFF10B981); // Emerald Green (Aman)
  static const Color riskSafeBg = Color(0xFFD1FAE5);
  
  static const Color riskWarning = Color(0xFFEAB308); // Amber Yellow (Waspada)
  static const Color riskWarningBg = Color(0xFFFEF9C3);
  
  static const Color riskVulnerable = Color(0xFFF97316); // Orange (Rentan)
  static const Color riskVulnerableBg = Color(0xFFFFEDD5);
  
  static const Color riskCritical = Color(0xFFEF4444); // Coral Red (Kritis)
  static const Color riskCriticalBg = Color(0xFFFEE2E2);

  // Common gradients
  static const List<Color> primaryGradient = [
    Color(0xFF0F766E),
    Color(0xFF0D9488),
  ];
}
