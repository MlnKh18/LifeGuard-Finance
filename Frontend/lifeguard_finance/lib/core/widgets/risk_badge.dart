import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum RiskLevel {
  safe,         // Aman
  warning,      // Waspada
  vulnerable,   // Rentan
  critical,     // Kritis
}

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final String? customLabel;

  const RiskBadge({
    super.key,
    required this.level,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (level) {
      case RiskLevel.safe:
        backgroundColor = AppColors.riskSafeBg;
        textColor = AppColors.riskSafe;
        label = 'Aman';
        icon = Icons.check_circle_outline_rounded;
        break;
      case RiskLevel.warning:
        backgroundColor = AppColors.riskWarningBg;
        textColor = AppColors.riskWarning;
        label = 'Waspada';
        icon = Icons.info_outline_rounded;
        break;
      case RiskLevel.vulnerable:
        backgroundColor = AppColors.riskVulnerableBg;
        textColor = AppColors.riskVulnerable;
        label = 'Rentan';
        icon = Icons.warning_amber_rounded;
        break;
      case RiskLevel.critical:
        backgroundColor = AppColors.riskCriticalBg;
        textColor = AppColors.riskCritical;
        label = 'Kritis';
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            customLabel ?? label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
