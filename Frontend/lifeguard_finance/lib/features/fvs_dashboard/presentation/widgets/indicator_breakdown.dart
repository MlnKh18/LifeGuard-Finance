import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/fvs_score_entity.dart';

class IndicatorBreakdown extends StatelessWidget {
  final FvsScore fvsScore;

  const IndicatorBreakdown({super.key, required this.fvsScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIndicatorRow(
          title: 'S1: Stabilitas Pendapatan',
          value: fvsScore.s1,
          description: 'Mengukur proporsi pendapatan tetap bulanan terhadap pendapatan fluktuatif.',
        ),
        _buildIndicatorRow(
          title: 'S2: Rasio Pengeluaran Rutin',
          value: fvsScore.s2,
          description: 'Mengukur seberapa besar pendapatan yang habis untuk pengeluaran dasar.',
        ),
        _buildIndicatorRow(
          title: 'S3: Cakupan Dana Darurat',
          value: fvsScore.s3,
          description: 'Kapasitas tabungan likuid untuk menutupi pengeluaran bulanan rutin.',
        ),
        _buildIndicatorRow(
          title: 'S4: Beban Cicilan/Utang',
          value: fvsScore.s4,
          description: 'Rasio kewajiban utang/cicilan bulanan terhadap total pendapatan.',
        ),
        _buildIndicatorRow(
          title: 'S5: Tanggungan Keluarga',
          value: fvsScore.s5,
          description: 'Menganalisis tingkat resiliensi finansial berdasarkan rasio tanggungan.',
        ),
        _buildIndicatorRow(
          title: 'S6: Kesiapan Proteksi Kesehatan',
          value: fvsScore.s6,
          description: 'Ketersediaan asuransi kesehatan/BPJS untuk meminimalisasi shock medis.',
        ),
        _buildIndicatorRow(
          title: 'S7: Kapasitas Surplus Arus Kas',
          value: fvsScore.s7,
          description: 'Sisa kas bersih setelah pengeluaran rutin dan pembayaran cicilan.',
        ),
      ],
    );
  }

  Widget _buildIndicatorRow({
    required String title,
    required double value,
    required String description,
  }) {
    Color indicatorColor;
    if (value >= 80) {
      indicatorColor = AppColors.riskSafe;
    } else if (value >= 60) {
      indicatorColor = AppColors.riskWarning;
    } else if (value >= 40) {
      indicatorColor = AppColors.riskVulnerable;
    } else {
      indicatorColor = AppColors.riskCritical;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 14)),
              Text(
                '${value.toStringAsFixed(0)}/100',
                style: AppTextStyles.bodySmall.copyWith(
                  color: indicatorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
