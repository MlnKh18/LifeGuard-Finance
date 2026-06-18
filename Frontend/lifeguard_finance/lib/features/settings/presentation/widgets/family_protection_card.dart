import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class FamilyProtectionCard extends StatelessWidget {
  final int dependentsCount;
  final bool hasBpjs;
  final bool hasInsurance;

  const FamilyProtectionCard({
    super.key,
    required this.dependentsCount,
    required this.hasBpjs,
    required this.hasInsurance,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Proteksi Keluarga', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah Tanggungan', style: AppTextStyles.bodyMedium),
              Text(
                '$dependentsCount Jiwa',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status BPJS', style: AppTextStyles.bodyMedium),
              _buildStatusBadge(hasBpjs),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Asuransi Tambahan', style: AppTextStyles.bodyMedium),
              _buildStatusBadge(hasInsurance),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Proteksi dasar membantu keluarga bertahan saat menghadapi biaya kesehatan atau risiko mendadak.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.riskSafe.withValues(alpha: 0.1) : AppColors.riskCritical.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Tidak Ada',
        style: AppTextStyles.bodySmall.copyWith(
          color: isActive ? AppColors.riskSafe : AppColors.riskCritical,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
