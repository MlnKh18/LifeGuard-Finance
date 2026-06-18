import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/currency_formatter.dart';

class FinancialSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double monthlyExpense;
  final double monthlyDebtPayment;
  final double liquidSavings;

  const FinancialSummaryCard({
    super.key,
    required this.totalIncome,
    required this.monthlyExpense,
    required this.monthlyDebtPayment,
    required this.liquidSavings,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Ringkasan Keuangan', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          _buildItem('Total Pendapatan', totalIncome, AppColors.riskSafe),
          const Divider(height: 24),
          _buildItem('Pengeluaran Rutin', monthlyExpense, AppColors.riskWarning),
          const SizedBox(height: 12),
          _buildItem('Cicilan Bulanan', monthlyDebtPayment, AppColors.riskCritical),
          const Divider(height: 24),
          _buildItem('Dana Darurat / Likuid', liquidSavings, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildItem(String label, double value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          CurrencyFormatter.formatRupiah(value),
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
