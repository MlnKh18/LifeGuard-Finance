import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../bloc/recommendation_cubit.dart';
import '../bloc/recommendation_state.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecommendationCubit>(
      create: (context) => getIt<RecommendationCubit>()..loadRecommendations(),
      child: TaskDetailView(taskId: taskId),
    );
  }
}

class TaskDetailView extends StatelessWidget {
  final String taskId;

  const TaskDetailView({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Tugas Mitigasi', style: AppTextStyles.heading3)),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state is! RecommendationLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final matches = state.tasks.where((t) => t.id == taskId);
          final task = matches.isEmpty ? null : matches.first;
          if (task == null) {
            return Center(child: Text('Tugas tidak ditemukan.', style: AppTextStyles.bodyMedium));
          }

          return _buildContent(context, task);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Recommendation task) {
    final priorityColor = _priorityColor(task.priority);
    final steps = task.description
        .split('. ')
        .map((s) => s.trim().replaceAll(RegExp(r'\.$'), ''))
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: priorityColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(Icons.task_alt_rounded, size: 56, color: priorityColor)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: priorityColor.withAlpha(80)),
                    ),
                    child: Text(
                      _priorityLabel(task.priority),
                      style: AppTextStyles.bodySmall.copyWith(color: priorityColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.timeline,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(task.title, style: AppTextStyles.heading1.copyWith(fontSize: 24)),
              const SizedBox(height: 20),
              Text('Mengapa Ini Penting?', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                'Tugas ini diprioritaskan ${_priorityLabel(task.priority).toLowerCase()} karena berkontribusi langsung pada Skor Vitalitas Finansial keluarga Anda. '
                'Menyelesaikannya dalam jangka waktu ${task.timeline} akan membantu memperkuat ketahanan keuangan Anda menghadapi krisis.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text('Langkah-Langkah', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              ...steps.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            '${entry.key + 1}',
                            style: AppTextStyles.label.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value, style: AppTextStyles.bodyMedium)),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
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
                    Expanded(
                      child: Text(_expertTip(task.timeline), style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareGuide(context, task),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Bagikan Panduan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<RecommendationCubit>().toggleTask(task.id),
                    icon: Icon(task.isCompleted ? Icons.check_circle_rounded : Icons.check_rounded, size: 18),
                    label: Text(task.isCompleted ? 'Selesai' : 'Tandai Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted ? AppColors.riskSafe : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _shareGuide(BuildContext context, Recommendation task) {
    final guide = '${task.title}\n\n${task.description}\n\nPrioritas: ${_priorityLabel(task.priority)} | Target: ${task.timeline}';
    Clipboard.setData(ClipboardData(text: guide));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Panduan disalin ke clipboard.'), backgroundColor: AppColors.primary),
    );
  }

  String _expertTip(String timeline) {
    switch (timeline) {
      case '30 Hari':
        return 'Fokuskan energi Anda di sini dulu — tindakan jangka pendek ini punya dampak paling cepat terhadap stabilitas finansial keluarga.';
      case '60 Hari':
        return 'Gunakan momentum dari pencapaian 30 hari pertama untuk menjaga konsistensi menyelesaikan tugas ini.';
      default:
        return 'Tugas jangka panjang ini membangun fondasi ketahanan finansial yang lebih kuat — jangan terburu-buru, fokus pada konsistensi.';
    }
  }
}

String _priorityLabel(RecommendationPriority p) {
  switch (p) {
    case RecommendationPriority.high:
      return 'Tinggi';
    case RecommendationPriority.medium:
      return 'Sedang';
    case RecommendationPriority.low:
      return 'Rendah';
  }
}

Color _priorityColor(RecommendationPriority p) {
  switch (p) {
    case RecommendationPriority.high:
      return AppColors.riskCritical;
    case RecommendationPriority.medium:
      return AppColors.riskWarning;
    case RecommendationPriority.low:
      return AppColors.riskSafe;
  }
}
