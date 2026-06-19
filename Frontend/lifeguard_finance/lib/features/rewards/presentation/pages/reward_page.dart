import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/reward_badge.dart';
import '../../domain/entities/reward_point.dart';
import '../../domain/entities/reward_summary.dart';
import '../bloc/reward_cubit.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('================ REWARD PAGE OPENED ================');
    return BlocProvider<RewardCubit>(
      create: (context) => getIt<RewardCubit>()..loadRewardSummary(),
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
          if (state is RewardLoading || state is RewardInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RewardError) {
            return Center(child: Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)));
          }

          if (state is RewardLoaded) {
            final summary = state.summary;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(summary),
                const SizedBox(height: 24),
                Text('Tingkatan Badge', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                _buildBadgeSection(summary),
                const SizedBox(height: 24),
                Text('Riwayat Transaksi', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                _buildTransactionList(summary.transactions),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSummaryCard(RewardSummary summary) {
    return AppCard(
      color: AppColors.primaryContainer,
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, size: 56, color: AppColors.onPrimaryContainer),
          const SizedBox(height: 8),
          Text(
            '${summary.totalPoints}',
            style: AppTextStyles.dataDisplay.copyWith(fontSize: 36, color: AppColors.onPrimaryContainer),
          ),
          Text('Total Poin', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimaryContainer)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(60),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Badge Aktif: ${summary.activeBadge?.badgeName ?? "None"}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          if (summary.nextBadge != null) ...[
            const SizedBox(height: 12),
            Text(
              '${summary.pointsToNextBadge} poin lagi menuju ${summary.nextBadge!.badgeName}',
              style: AppTextStyles.dataLabel.copyWith(color: AppColors.onPrimaryContainer),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeSection(RewardSummary summary) {
    return Column(
      children: summary.badges.map<Widget>((RewardBadge badge) {
        final isUnlocked = summary.totalPoints >= badge.minPoints;
        final isActive = badge == summary.activeBadge;
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          borderRadius: 8.0,
          color: isActive ? AppColors.primaryContainer : AppColors.surface,
          child: Row(
            children: [
              Icon(
                isActive ? Icons.military_tech_rounded : Icons.military_tech_outlined,
                color: isUnlocked
                    ? (isActive ? AppColors.onPrimaryContainer : AppColors.primary)
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.badgeName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                        color: isUnlocked
                            ? (isActive ? AppColors.onPrimaryContainer : AppColors.textPrimary)
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      badge.description,
                      style: AppTextStyles.dataLabel.copyWith(
                        color: isUnlocked
                            ? (isActive ? AppColors.onPrimaryContainer : AppColors.textSecondary)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                Icon(
                  Icons.check_circle_rounded,
                  color: isActive ? AppColors.onPrimaryContainer : AppColors.primary,
                  size: 18,
                )
              else
                Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionList(List<RewardPoint> transactions) {
    if (transactions.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Belum ada reward. Selesaikan modul edukasi atau target tabungan untuk mulai mengumpulkan poin.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: transactions.map((t) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rewardActivityTypeLabel(t.activityType),
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(t.description, style: AppTextStyles.dataLabel),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(t.createdAt),
                      style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${t.points}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
