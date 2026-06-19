import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/literacy_module.dart';
import '../../domain/repositories/literacy_repository.dart';
import '../bloc/literacy_cubit.dart';

class LiteracyPage extends StatelessWidget {
  const LiteracyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiteracyCubit>(
      create: (context) => getIt<LiteracyCubit>()..loadProgress(),
      child: const LiteracyView(),
    );
  }
}

class LiteracyView extends StatelessWidget {
  const LiteracyView({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = getIt<LiteracyRepository>().getModules();
    return Scaffold(
      appBar: AppBar(title: Text('Literasi Finansial', style: AppTextStyles.heading3)),
      body: BlocBuilder<LiteracyCubit, LiteracyProgressState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              AppCard(
                color: AppColors.primaryContainer,
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.onPrimaryContainer, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.readCount} dari ${modules.length} modul dibaca',
                            style: AppTextStyles.heading3.copyWith(color: AppColors.onPrimaryContainer, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Setiap modul yang dibaca memberi +3 poin reward.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Modul Edukasi', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              ...modules.map((module) => _buildModuleTile(context, module, state.isRead(module.moduleId))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, LiteracyModule module, bool isRead) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 8.0,
      showShadow: true,
      onTap: () => context.push('/literacy/${module.moduleId}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRead ? Icons.check_circle_rounded : Icons.menu_book_outlined,
            color: isRead ? AppColors.riskSafe : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(module.relatedIndicator, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text('${module.durationMinutes} menit baca', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
