import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class IndicatorCard extends StatelessWidget {
  final String title;
  final int score;
  final IconData icon;
  final String description;
  final VoidCallback? onTap;

  const IndicatorCard({
    super.key,
    required this.title,
    required this.score,
    required this.icon,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getScoreColor(score);
    final statusCategory = AppColors.getScoreCategory(score);

    return InkWell(
      onTap: onTap,
      borderRadius: AppStyles.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(AppStyles.m),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Title + Score Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.s),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: AppStyles.radiusSmall,
                  ),
                  child: Icon(icon, color: statusColor, size: 20),
                ),
                const SizedBox(width: AppStyles.s),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppStyles.s, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: AppStyles.radiusCircular,
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.m),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: score / 100.0,
                backgroundColor: AppColors.surfaceCard.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
            
            const SizedBox(height: AppStyles.s),
            
            // Description & Status Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppStyles.s),
                Text(
                  statusCategory,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
