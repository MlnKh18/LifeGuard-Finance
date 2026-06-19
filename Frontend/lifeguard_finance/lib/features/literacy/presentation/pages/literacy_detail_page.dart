import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../rewards/presentation/bloc/reward_cubit.dart';
import '../../domain/entities/literacy_module.dart';
import '../../domain/repositories/literacy_repository.dart';
import '../bloc/literacy_cubit.dart';

class LiteracyDetailPage extends StatelessWidget {
  final String moduleId;

  const LiteracyDetailPage({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LiteracyCubit>(create: (context) => getIt<LiteracyCubit>()..loadProgress()),
        BlocProvider<RewardCubit>(create: (context) => getIt<RewardCubit>()..loadPoints()),
      ],
      child: LiteracyDetailView(moduleId: moduleId),
    );
  }
}

class LiteracyDetailView extends StatelessWidget {
  final String moduleId;

  const LiteracyDetailView({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final matches = getIt<LiteracyRepository>().getModules().where((m) => m.moduleId == moduleId);
    final module = matches.isEmpty ? null : matches.first;

    return Scaffold(
      appBar: AppBar(title: Text('Detail Modul', style: AppTextStyles.heading3)),
      body: module == null
          ? Center(child: Text('Modul tidak ditemukan.', style: AppTextStyles.bodyMedium))
          : BlocBuilder<LiteracyCubit, LiteracyProgressState>(
              builder: (context, state) => _buildContent(context, module, state.isRead(module.moduleId)),
            ),
    );
  }

  Widget _buildContent(BuildContext context, LiteracyModule module, bool isRead) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      module.relatedIndicator,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${module.durationMinutes} menit', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Text(module.title, style: AppTextStyles.heading1.copyWith(fontSize: 24)),
              const SizedBox(height: 8),
              Text(module.summary, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              Text('Isi Edukasi', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(module.content, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tertiaryContainer.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: AppColors.tertiaryContainer, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(module.tips, style: AppTextStyles.bodySmall)),
                  ],
                ),
              ),
              if (module.externalUrl != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(module.externalUrl!), mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Baca Sumber Eksternal'),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRead ? null : () => _markAsRead(context, module),
                icon: Icon(isRead ? Icons.check_circle_rounded : Icons.check_rounded, size: 18),
                label: Text(isRead ? 'Sudah Dibaca' : 'Tandai Sudah Dibaca (+3 Poin)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRead ? AppColors.riskSafe : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markAsRead(BuildContext context, LiteracyModule module) async {
    final literacyCubit = context.read<LiteracyCubit>();
    final rewardCubit = context.read<RewardCubit>();
    await literacyCubit.markAsRead(module.moduleId);
    await rewardCubit.addPoints(3);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modul ditandai sudah dibaca. +3 poin reward!'), backgroundColor: AppColors.primary),
    );
  }
}
