import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/literacy_cubit.dart';
import '../bloc/literacy_state.dart';

class LiteracyPage extends StatefulWidget {
  const LiteracyPage({super.key});

  @override
  State<LiteracyPage> createState() => _LiteracyPageState();
}

class _LiteracyPageState extends State<LiteracyPage> {
  String _selectedIndicator = 'Semua';
  final List<String> _indicators = ['Semua', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'];

  @override
  Widget build(BuildContext context) {
    debugPrint('================ LITERACY PAGE OPENED ================');
    return BlocProvider<LiteracyCubit>(
      create: (context) => getIt<LiteracyCubit>()..loadModules([]),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edukasi Keuangan', style: AppTextStyles.heading3),
        ),
        body: BlocBuilder<LiteracyCubit, LiteracyState>(
          builder: (context, state) {
            if (state is LiteracyLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LiteracyError) {
              return Center(child: Text(state.message, style: AppTextStyles.bodyMedium));
            } else if (state is LiteracyLoaded) {
              final modules = state.modules.where((m) {
                if (_selectedIndicator == 'Semua') return true;
                return m.relatedIndicator == _selectedIndicator;
              }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<LiteracyCubit>().loadModules([]);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Pelajari topik keuangan keluarga berdasarkan kondisi finansialmu.', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),

                    // Progress Belajar
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progress Belajar', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: state.summary.totalModules > 0 ? state.summary.readModules / state.summary.totalModules : 0,
                                    backgroundColor: AppColors.border,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text('${state.summary.readModules} / ${state.summary.totalModules} Modul', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _indicators.map((ind) {
                          final isSelected = _selectedIndicator == ind;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(ind),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  _selectedIndicator = ind;
                                });
                              },
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primary,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Modules List
                    if (modules.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('Modul tidak ditemukan.', style: AppTextStyles.bodyMedium),
                        ),
                      )
                    else
                      ...modules.map((module) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            onTap: () => context.push('/literacy/${module.moduleId}'),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(module.title, style: AppTextStyles.heading3),
                                const SizedBox(height: 8),
                                Text(
                                  module.summary,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('${module.durationMinutes} menit', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                    const Spacer(),
                                    PrimaryButton(
                                      text: 'Baca',
                                      width: 80,
                                      height: 36,
                                      onPressed: () => context.push('/literacy/${module.moduleId}'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
