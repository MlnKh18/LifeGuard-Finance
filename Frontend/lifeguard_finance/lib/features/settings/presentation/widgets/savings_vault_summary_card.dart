import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/currency_formatter.dart';

class SavingsVaultSummaryCard extends StatelessWidget {
  final int vaultCount;
  final double totalVaultTarget;
  final double totalVaultSaved;
  final double averageVaultProgress;

  const SavingsVaultSummaryCard({
    super.key,
    required this.vaultCount,
    required this.totalVaultTarget,
    required this.totalVaultSaved,
    required this.averageVaultProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (vaultCount == 0) {
      return AppCard(
        child: Column(
          children: [
            const Icon(Icons.savings_outlined, color: AppColors.primary, size: 40),
            const SizedBox(height: 12),
            Text(
              'Belum ada target tabungan keluarga.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Buat Vault',
              onPressed: () => context.push('/savings-vault'),
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
            children: [
              const Icon(Icons.savings, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Savings Vault', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vault Aktif', style: AppTextStyles.bodyMedium),
              Text(
                '$vaultCount Vault',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Target', style: AppTextStyles.bodyMedium),
              Text(
                CurrencyFormatter.formatRupiah(totalVaultTarget),
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terkumpul', style: AppTextStyles.bodyMedium),
              Text(
                CurrencyFormatter.formatRupiah(totalVaultSaved),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.riskSafe,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: averageVaultProgress.clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Rata-rata progres: ${(averageVaultProgress * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Lihat Detail Vault',
            onPressed: () => context.push('/savings-vault'),
          ),
        ],
      ),
    );
  }
}
