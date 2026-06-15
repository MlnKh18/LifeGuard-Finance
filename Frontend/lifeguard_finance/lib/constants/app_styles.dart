import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Spacing (Margins / Paddings)
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radii
  static final BorderRadius radiusSmall = BorderRadius.circular(8.0);
  static final BorderRadius radiusMedium = BorderRadius.circular(16.0);
  static final BorderRadius radiusLarge = BorderRadius.circular(24.0);
  static final BorderRadius radiusCircular = BorderRadius.circular(999.0);

  // Paddings
  static const EdgeInsets paddingAllS = EdgeInsets.all(s);
  static const EdgeInsets paddingAllM = EdgeInsets.all(m);
  static const EdgeInsets paddingAllL = EdgeInsets.all(l);
  static const EdgeInsets paddingSymmetricH = EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets paddingSymmetricV = EdgeInsets.symmetric(vertical: m);

  // Card Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: radiusMedium,
    border: Border.all(color: AppColors.surfaceCard.withOpacity(0.5), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: AppColors.surface.withOpacity(0.7),
    borderRadius: radiusMedium,
    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Input Field Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    String hintText = '',
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      suffixStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: AppColors.surface.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: m, vertical: m),
      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: AppColors.surfaceCard.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: AppColors.surfaceCard.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(color: AppColors.critical, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(color: AppColors.critical, width: 2),
      ),
    );
  }
}
