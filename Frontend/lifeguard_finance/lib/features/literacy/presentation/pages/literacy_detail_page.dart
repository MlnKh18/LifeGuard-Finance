import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/url_helper.dart';
import '../bloc/literacy_cubit.dart';
import '../bloc/literacy_state.dart';

class LiteracyDetailPage extends StatelessWidget {
  final String moduleId;

  const LiteracyDetailPage({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    debugPrint('================ LITERACY DETAIL OPENED ================');
    debugPrint('moduleId: $moduleId');

    return BlocProvider<LiteracyCubit>(
      create: (context) => getIt<LiteracyCubit>()..loadDetail(moduleId),
      child: const LiteracyDetailView(),
    );
  }
}

class LiteracyDetailView extends StatelessWidget {
  const LiteracyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Edukasi', style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<LiteracyCubit, LiteracyState>(
        builder: (context, state) {
          if (state is LiteracyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LiteracyError) {
            return Center(child: Text(state.message, style: AppTextStyles.bodyMedium));
          } else if (state is LiteracyDetailLoaded) {
            final module = state.module;
            final isRead = state.isRead;

            debugPrint('module title: ${module.title}');
            debugPrint('source: ${module.sourceName}');
            debugPrint('externalUrl: ${module.externalUrl}');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 12),
                        Text(module.title, style: AppTextStyles.heading2),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${module.durationMinutes} menit baca', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            const Spacer(),
                            if (module.sourceName != null) ...[
                              Icon(Icons.menu_book, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(module.sourceName!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  Text(module.summary, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Content
                  Text(module.content, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
                  const SizedBox(height: 24),

                  // Key Takeaways
                  if (module.keyTakeaways.isNotEmpty) ...[
                    Text('Poin Penting', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    AppCard(
                      color: AppColors.primaryContainer,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: module.keyTakeaways.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(tip, style: AppTextStyles.bodyMedium)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Practical Tips
                  if (module.practicalTips.isNotEmpty) ...[
                    Text('Tips Praktis', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: module.practicalTips.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.secondary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(tip, style: AppTextStyles.bodyMedium)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Source Article Card
                  if (module.externalUrl != null && module.sourceName != null) ...[
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('Sumber Edukasi', style: AppTextStyles.heading3),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(module.sourceName!, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Buka artikel sumber untuk membaca penjelasan lengkap.', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
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
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.open_in_new, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Buka Sumber Edukasi', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Button
                  if (!isRead)
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Tandai Selesai',
                        onPressed: () {
                          context.read<LiteracyCubit>().markAsRead(module.moduleId, []);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Progress belajar disimpan.')),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.riskSafe.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.riskSafe),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.riskSafe),
                          const SizedBox(width: 8),
                          Text('Modul Selesai Dibaca', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.riskSafe, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Materi edukasi ini bersifat informatif dan tidak menggantikan nasihat keuangan profesional.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
