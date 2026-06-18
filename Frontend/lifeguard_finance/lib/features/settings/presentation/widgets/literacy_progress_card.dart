import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';

class LiteracyProgressCard extends StatelessWidget {
  final int readCount;
  final int totalCount;

  const LiteracyProgressCard({
    super.key,
    required this.readCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    if (readCount == 0) {
      return AppCard(
        child: Column(
          children: [
            const Icon(Icons.menu_book, color: AppColors.primary, size: 40),
            const SizedBox(height: 12),
            Text(
              'Belum ada modul yang dibaca.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Mulai Belajar',
              onPressed: () => context.push('/literacy'),
            ),
          ],
        ),
      );
    }

    final double progress = totalCount > 0 ? (readCount / totalCount) : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Progress Literasi', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Modul Dibaca', style: AppTextStyles.bodyMedium),
              Text(
                '$readCount / $totalCount Modul',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            color: AppColors.secondary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Selesai: ${(progress * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Lanjutkan Belajar',
            onPressed: () => context.push('/literacy'),
          ),
        ],
      ),
    );
  }
}
