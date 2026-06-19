import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../bloc/recommendation_cubit.dart';
import '../bloc/recommendation_state.dart';

const _timelines = ['30 Hari', '60 Hari', '90 Hari'];

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecommendationCubit>(
      create: (context) => getIt<RecommendationCubit>()..loadRecommendations(),
      child: const RecommendationView(),
    );
  }
}

class RecommendationView extends StatefulWidget {
  const RecommendationView({super.key});

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _timelines.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rencana Mitigasi', style: AppTextStyles.heading3),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
            onPressed: () => context.push('/profile-settings'),
          ),
        ],
      ),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state is RecommendationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is RecommendationNoProfile) {
            return _buildNoProfileView(context);
          }

          if (state is RecommendationError) {
            return _buildErrorView(context, state.message);
          }

          if (state is RecommendationLoaded) {
            return _buildContent(context, state.tasks);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Recommendation> tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: AppCard(
            color: Color.alphaBlend(AppColors.primary.withAlpha(13), Colors.white),
            showShadow: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progress Keseluruhan', style: AppTextStyles.heading3),
                        const SizedBox(height: 2),
                        Text('Fase Mitigasi Darurat', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.dataDisplay.copyWith(fontSize: 28, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  icon: Icons.alt_route_rounded,
                  label: 'Smart Routing',
                  onTap: () => context.push('/smart-routing'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  icon: Icons.savings_rounded,
                  label: 'Savings Vault',
                  onTap: () => context.push('/savings-vault'),
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          tabs: _timelines.map((t) => Tab(text: t)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _timelines.map((timeline) {
              final filtered = tasks.where((t) => t.timeline == timeline).toList();
              return _buildTaskList(context, filtered);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      borderRadius: 12.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Recommendation> tasks) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Tidak ada tugas untuk periode ini.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...tasks.map((task) => _buildTaskTile(context, task)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showAddTaskDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text('Tambah Tugas Baru', style: AppTextStyles.heading3.copyWith(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, Recommendation task) {
    final priorityColor = _priorityColor(task.priority);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => context.push('/recommendation/${task.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onTap: () => context.read<RecommendationCubit>().toggleTask(task.id),
                  child: Icon(
                    task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: task.isCompleted ? 0.6 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTextStyles.heading3.copyWith(
                                fontSize: 14,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: priorityColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: priorityColor.withAlpha(80)),
                            ),
                            child: Text(
                              _priorityLabel(task.priority),
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: priorityColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(task.description, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!task.isCompleted) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  context.push('/savings-vault', extra: {
                    'name': task.title,
                    'purpose': task.description,
                  });
                },
                icon: const Icon(Icons.savings_rounded, size: 16),
                label: const Text('Buat Target Tabungan'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final cubit = context.read<RecommendationCubit>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String timeline = _timelines.first;
    RecommendationPriority priority = RecommendationPriority.medium;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Tugas Baru'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Judul Tugas'),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Judul wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Deskripsi'),
                        maxLines: 2,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: timeline,
                        decoration: const InputDecoration(labelText: 'Target Waktu'),
                        items: _timelines.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setDialogState(() => timeline = val ?? timeline),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecommendationPriority>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Prioritas'),
                        items: RecommendationPriority.values
                            .map((p) => DropdownMenuItem(value: p, child: Text(_priorityLabel(p))))
                            .toList(),
                        onChanged: (val) => setDialogState(() => priority = val ?? priority),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    cubit.addCustomTask(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      timeline: timeline,
                      priority: priority,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNoProfileView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom_rounded, size: 100, color: AppColors.border),
          const SizedBox(height: 24),
          Text('Profil Keuangan Belum Lengkap', style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Lengkapi data profil keuangan keluarga terlebih dahulu untuk mendapatkan rencana mitigasi yang dipersonalisasi.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Lengkapi Profil Sekarang',
            onPressed: () => context.go('/family-profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: () => context.read<RecommendationCubit>().loadRecommendations(),
          ),
        ],
      ),
    );
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
