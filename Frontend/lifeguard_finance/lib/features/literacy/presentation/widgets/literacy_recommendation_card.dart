import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/url_helper.dart';
import '../../domain/entities/literacy_module.dart';

class LiteracyRecommendationCard extends StatelessWidget {
  final LiteracyModule module;

  const LiteracyRecommendationCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    debugPrint('================ DASHBOARD LITERACY SUMMARY ================');
    debugPrint('recommendedModule: ${module.title}');
    debugPrint('moduleId: ${module.moduleId}');
    debugPrint('indicator: ${module.relatedIndicator}');
    debugPrint('externalUrl: ${module.externalUrl}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Edukasi Keuangan Pilihan', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        AppCard(
          child: InkWell(
            onTap: () => context.push('/literacy/${module.moduleId}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          module.title,
                          style: AppTextStyles.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${module.relatedIndicator} ${module.topic}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${module.durationMinutes} menit baca',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    module.summary,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  if (module.sourceName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.menu_book, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Sumber: ${module.sourceName}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        if (module.externalUrl != null)
                          InkWell(
                            onTap: () async {
                              try {
                                await openExternalUrl(module.externalUrl!);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                            child: Row(
                              children: [
                                Text('Buka Sumber', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                                const SizedBox(width: 4),
                                Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Baca Modul',
                      onPressed: () => context.push('/literacy/${module.moduleId}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
