import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text styles. Per the Stitch design system, `Outfit` is the
/// primary UI font (headings/body/labels) and `Inter` is reserved for
/// numeric/tabular data (scores, currency). `GoogleFonts` is only ever
/// called from this file — widgets should consume these constants rather
/// than calling `GoogleFonts.*` themselves, so the font stays centrally
/// themeable.
class AppTextStyles {
  AppTextStyles._();

  // Headings (Outfit)
  static final TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static final TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Texts (Outfit)
  static final TextStyle bodyLarge = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static final TextStyle bodyMedium = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static final TextStyle bodySmall = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Special styles (Outfit)
  static final TextStyle button = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static final TextStyle label = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  // Numeric/tabular data (Inter) — use for FVS scores, currency, percentages.
  static final TextStyle dataDisplay = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static final TextStyle dataLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );
}
