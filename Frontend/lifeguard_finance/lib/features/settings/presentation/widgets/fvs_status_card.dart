import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/risk_badge.dart';

class FvsStatusCard extends StatelessWidget {
  final double score;
  final String category;

  const FvsStatusCard({
    super.key,
    required this.score,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    if (score < 0) {
      return AppCard(
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 40),
            const SizedBox(height: 12),
            Text(
              'Skor FVS belum tersedia. Lengkapi profil keuangan keluarga untuk menghitung kondisi finansial Anda.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Lengkapi Profil',
              onPressed: () {
                context.push('/family-profile');
              },
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Skor FVS Saat Ini', style: AppTextStyles.heading3),
              RiskBadge(level: _getRiskLevel(score)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                score.toStringAsFixed(1),
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kategori: $category. Periksa dasbor untuk detail indikator.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Lihat Dashboard',
            onPressed: () {
              context.push('/dashboard');
            },
          ),
        ],
      ),
    );
  }

  RiskLevel _getRiskLevel(double score) {
    if (score >= 80) return RiskLevel.safe;
    if (score >= 60) return RiskLevel.warning;
    if (score >= 40) return RiskLevel.vulnerable;
    return RiskLevel.critical;
  }
}
