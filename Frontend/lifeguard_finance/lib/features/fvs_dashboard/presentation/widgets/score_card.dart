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
        borderRadius: BorderRadius.circular(24),
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
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fvsScore.score.toStringAsFixed(0),
                      style: AppTextStyles.heading1.copyWith(fontSize: 40, color: scoreColor),
                    ),
                    const Text('Skor FVS', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kategori: ${fvsScore.category}',
            style: AppTextStyles.heading2.copyWith(color: scoreColor),
          ),
          const SizedBox(height: 8),
          Text(
            fvsScore.description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
