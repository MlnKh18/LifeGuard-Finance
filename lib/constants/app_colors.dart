import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Slate Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Bright Blue
  static const Color accent = Color(0xFF0D9488); // Teal
  
  // Background Colors (Premium Dark Slate Theme)
  static const Color background = Color(0xFF0F172A); // Dark Slate Blue
  static const Color surface = Color(0xFF1E293B); // Muted Slate
  static const Color surfaceCard = Color(0xFF334155); // Card Slate
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted Blue-grey
  static const Color textMuted = Color(0xFF64748B); // Slate Grey
  
  // Financial Vulnerability Status Colors (Detect Pilar)
  static const Color safe = Color(0xFF10B981); // Emerald Green (Score > 70)
  static const Color warning = Color(0xFFF59E0B); // Amber Yellow (Score 55 - 70)
  static const Color vulnerable = Color(0xFFF97316); // Orange (Score 40 - 54)
  static const Color critical = Color(0xFFEF4444); // Crimson Red (Score < 40)
  
  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, Color(0xFF1D4ED8), accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color getScoreColor(int score) {
    if (score >= 70) return safe;
    if (score >= 55) return warning;
    if (score >= 40) return vulnerable;
    return critical;
  }

  static String getScoreCategory(int score) {
    if (score >= 70) return 'Aman';
    if (score >= 55) return 'Waspada';
    if (score >= 40) return 'Rentan';
    return 'Kritis';
  }
}
