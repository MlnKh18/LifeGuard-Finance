import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/fvs_score_entity.dart';

class ScoreCard extends StatelessWidget {
  final FvsScore fvsScore;

  const ScoreCard({super.key, required this.fvsScore});

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    switch (fvsScore.category.toLowerCase()) {
      case 'aman':
        scoreColor = AppColors.riskSafe;
        break;
      case 'waspada':
        scoreColor = AppColors.riskWarning;
        break;
      case 'rentan':
        scoreColor = AppColors.riskVulnerable;
        break;
      default:
        scoreColor = AppColors.riskCritical;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor Vitalitas Finansial',
                style: AppTextStyles.heading3,
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                onPressed: () => _showInfoDialog(context),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: fvsScore.score / 100,
                    strokeWidth: 14,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fvsScore.score.toStringAsFixed(0),
                      style: AppTextStyles.dataDisplay.copyWith(color: scoreColor),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        fvsScore.category,
                        style: AppTextStyles.dataLabel.copyWith(color: scoreColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fvsScore.description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Skor FVS'),
        content: const Text(
          'Financial Vulnerability Score (FVS) adalah skor edukatif 0-100 yang mengukur ketahanan finansial keluarga Anda berdasarkan 7 indikator: stabilitas pendapatan, rasio pengeluaran, dana darurat, beban utang, tanggungan, proteksi kesehatan, dan kapasitas surplus arus kas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
