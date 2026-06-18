import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Emerald Teal — Stitch design-system seed `overridePrimaryColor`)
  static const Color primary = Color(0xFF0D9488); // Emerald Teal
  static const Color primaryLight = Color(0xFF14B8A6); // Light Teal
  static const Color primaryDark = Color(0xFF115E59); // Dark Teal

  // Secondary Colors (Electric Blue — Stitch design-system seed `overrideSecondaryColor`)
  static const Color secondary = Color(0xFF3B82F6); // Electric Blue
  static const Color background = Color(0xFFF5FAF8); // Stitch light `background`
  static const Color surface = Colors.white; // Stitch light `surface-container-lowest`
  static const Color textPrimary = Color(0xFF171D1C); // Stitch light `on-surface`
  static const Color textSecondary = Color(0xFF3D4947); // Stitch light `on-surface-variant`
  static const Color border = Color(0xFFE2E8F0); // Stitch card border

  // Risk / Vulnerability Level Colors (Stitch design-system status tokens)
  static const Color riskSafe = Color(0xFF10B981); // status-safe (Aman)
  static const Color riskSafeBg = Color(0xFFD1FAE5);

  static const Color riskWarning = Color(0xFFF59E0B); // status-warning (Waspada)
  static const Color riskWarningBg = Color(0xFFFEF3C7);

  static const Color riskVulnerable = Color(0xFFF97316); // status-vulnerable (Rentan)
  static const Color riskVulnerableBg = Color(0xFFFFEDD5);

  static const Color riskCritical = Color(0xFFEF4444); // status-critical (Kritis)
  static const Color riskCriticalBg = Color(0xFFFEE2E2);

  // Common gradients
  static const List<Color> primaryGradient = [
    Color(0xFF0D9488),
    Color(0xFF115E59),
  ];
}
