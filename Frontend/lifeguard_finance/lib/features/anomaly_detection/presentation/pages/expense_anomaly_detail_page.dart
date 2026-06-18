import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/anomaly_combined_record.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

class ExpenseAnomalyDetailPage extends StatelessWidget {
  final AnomalyCombinedRecord record;

  const ExpenseAnomalyDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final anomaly = record.anomaly!;
    final r = record.record;

    // Map category to icon
    IconData iconData = Icons.receipt_long;
    if (r.category.toLowerCase().contains('groceries')) iconData = Icons.shopping_cart;
    if (r.category.toLowerCase().contains('transport')) iconData = Icons.directions_car;
    if (r.category.toLowerCase().contains('dining') || r.category.toLowerCase().contains('food')) iconData = Icons.restaurant;
    if (r.category.toLowerCase().contains('electronic')) iconData = Icons.devices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail Transaksi', style: AppTextStyles.heading3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton(
              onPressed: () {
                // Implement report logic
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.riskCritical),
                foregroundColor: AppColors.riskCritical,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Laporkan'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Details Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kategori', style: AppTextStyles.label),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(iconData, color: AppColors.primaryDark, size: 20),
                                const SizedBox(width: 8),
                                Text(r.category, style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Waktu', style: AppTextStyles.label),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_dateFormat.format(r.recordDate), style: AppTextStyles.bodyMedium),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Metode Pembayaran', style: AppTextStyles.label),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.credit_card, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Credit Card (**** 1234)', style: AppTextStyles.bodyMedium),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status', style: AppTextStyles.label),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.riskCritical,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Menunggu\nVerifikasi', style: AppTextStyles.bodyMedium),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security Analysis Section
            Text('Analisis Keamanan', style: AppTextStyles.heading2),
            const SizedBox(height: 16),

            // Warning Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.riskCriticalBg, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.riskCriticalBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium,
                            children: [
                              const TextSpan(text: 'Pengeluaran ini '),
                              TextSpan(
                                text: '${anomaly.increasePercentage.toStringAsFixed(0)}% lebih tinggi ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.riskCritical),
                              ),
                              TextSpan(
                                text: 'dari rata-rata kategori ${r.category} Anda (${_rupiahFormat.format(anomaly.averageAmount)}).',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rata-rata Bulanan', style: AppTextStyles.label),
                      Text('${_rupiahFormat.format(anomaly.averageAmount / 1000)}k', style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.4, // Mock visual relative ratio
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaksi Ini', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                      Text('${_rupiahFormat.format(r.amount / 1000)}k', style: AppTextStyles.label.copyWith(color: AppColors.riskCritical)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.riskCritical,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tip Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.primaryDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Saran: Pertimbangkan untuk membagi cicilan jika ini adalah pembelian aset jangka panjang agar arus kas bulanan Anda tetap terjaga.',
                      style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: 'Konfirmasi Transaksi',
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.riskCritical),
                    foregroundColor: AppColors.riskCritical,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Bukan Saya (Sanggah)', style: AppTextStyles.button.copyWith(color: AppColors.riskCritical)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
