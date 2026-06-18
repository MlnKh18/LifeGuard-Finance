import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/reward_badge.dart';
import '../bloc/reward_cubit.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardCubit>(
      create: (context) => getIt<RewardCubit>()..loadPoints(),
      child: const RewardView(),
    );
  }
}

class RewardView extends StatelessWidget {
  const RewardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reward Points', style: AppTextStyles.heading3)),
      body: BlocBuilder<RewardCubit, RewardState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                color: AppColors.primaryContainer,
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events_rounded, size: 56, color: AppColors.onPrimaryContainer),
                    const SizedBox(height: 8),
                    Text(
                      '${state.points}',
                      style: AppTextStyles.dataDisplay.copyWith(fontSize: 36, color: AppColors.onPrimaryContainer),
                    ),
                    Text('Total Poin Reward', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimaryContainer)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Badge: ${state.badge.name}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Cara Mendapatkan Poin', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              _earnTile(Icons.menu_book_rounded, 'Membaca modul edukasi', '+3 Poin'),
              _earnTile(Icons.forum_rounded, 'Membuat posting komunitas', '+10 Poin'),
              _earnTile(Icons.comment_rounded, 'Memberi komentar', '+5 Poin'),
              _earnTile(Icons.thumb_up_rounded, 'Komentar ditandai helpful', '+20 Poin'),
              _earnTile(Icons.savings_rounded, 'Menyelesaikan target vault', '+25 Poin'),
              const SizedBox(height: 24),
              Text('Tingkatan Badge', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              ...rewardBadges.map((badge) => _badgeTile(badge.name, badge == state.badge)),
            ],
          );
        },
      ),
    );
  }

  Widget _earnTile(IconData icon, String label, String points) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 8.0,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(points, style: AppTextStyles.dataLabel.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _badgeTile(String badge, bool isActive) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 8.0,
      color: isActive ? AppColors.primaryContainer : AppColors.surface,
      child: Row(
        children: [
          Icon(
            isActive ? Icons.military_tech_rounded : Icons.military_tech_outlined,
            color: isActive ? AppColors.onPrimaryContainer : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              badge,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.onPrimaryContainer : AppColors.textPrimary,
              ),
            ),
          ),
          if (isActive) const Icon(Icons.check_circle_rounded, color: AppColors.onPrimaryContainer, size: 18),
        ],
      ),
    );
  }
}
