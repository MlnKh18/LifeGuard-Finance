import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

/// A single metric tile for the Dashboard's bento grid (Dana Darurat, Rasio
/// Hutang, Rasio Menabung, Aset Likuid), matching the Stitch "Dashboard
/// Utama" layout: icon badge + title, a tabular value, a progress bar, and
/// a target/status footer row.
class MetricBentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;
  final double progress;
  final String targetLabel;
  final String statusLabel;

  const MetricBentoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
    required this.progress,
    required this.targetLabel,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.dataLabel.copyWith(color: accentColor, fontSize: 16),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  targetLabel,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                statusLabel,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: accentColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
