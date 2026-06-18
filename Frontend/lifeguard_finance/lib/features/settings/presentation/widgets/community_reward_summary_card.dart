import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class CommunityRewardSummaryCard extends StatelessWidget {
  final int postCount;
  final int commentCount;
  final int totalRewardPoints;
  final String activeBadge;

  const CommunityRewardSummaryCard({
    super.key,
    required this.postCount,
    required this.commentCount,
    required this.totalRewardPoints,
    required this.activeBadge,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Komunitas & Reward', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.forum_outlined,
                  value: postCount.toString(),
                  label: 'Post',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.comment_outlined,
                  value: commentCount.toString(),
                  label: 'Komentar',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Poin', style: AppTextStyles.bodySmall),
                  Text(
                    '$totalRewardPoints pts',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Badge Aktif', style: AppTextStyles.bodySmall),
                  Text(
                    activeBadge,
                    style: AppTextStyles.heading3.copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/community'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Komunitas'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/reward'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Rewards'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.heading3),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
