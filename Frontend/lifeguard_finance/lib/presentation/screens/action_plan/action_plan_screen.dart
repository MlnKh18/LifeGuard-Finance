import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/recommendation.dart';

class ActionPlanScreen extends ConsumerStatefulWidget {
  const ActionPlanScreen({super.key});

  @override
  ConsumerState<ActionPlanScreen> createState() => _ActionPlanScreenState();
}

class _ActionPlanScreenState extends ConsumerState<ActionPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _checkedTaskTitles = {}; // Simple local persistence for prototype checkbox states

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(recommendationsProvider);

    if (list.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rencana Mitigasi')),
        body: const Center(
          child: Text('Harap lengkapi profil keuangan Anda untuk menghasilkan rekomendasi.'),
        ),
      );
    }

    // Filter recommendations by period
    final tasks30 = list.where((t) => t.actionPeriod == '30 Hari').toList();
    final tasks60 = list.where((t) => t.actionPeriod == '60 Hari').toList();
    final tasks90 = list.where((t) => t.actionPeriod == '90 Hari').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Aksi Mitigasi'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: '30 Hari Pertama'),
            Tab(text: '60 Hari Kerja'),
            Tab(text: '90 Hari Rencana'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(tasks30, '30 Hari'),
          _buildTaskList(tasks60, '60 Hari'),
          _buildTaskList(tasks90, '90 Hari'),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Recommendation> tasks, String periodLabel) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.checkCircle2, color: AppColors.safe, size: 48),
            SizedBox(height: AppStyles.m),
            Text('Semua Aman!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Tidak ada tindakan mendesak untuk periode ini.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    // Calculate progress
    final completedCount = tasks.where((t) => _checkedTaskTitles.contains(t.title)).length;
    final double progress = tasks.isNotEmpty ? completedCount / tasks.length : 0.0;

    return Column(
      children: [
        // Progress Card
        Container(
          margin: const EdgeInsets.all(AppStyles.m),
          padding: const EdgeInsets.all(AppStyles.m),
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progres Tindakan Preventif', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.s),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceCard.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              const SizedBox(height: AppStyles.xs),
              Text(
                '$completedCount dari ${tasks.length} aksi selesai dikerjakan',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // List of tasks
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.m),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isChecked = _checkedTaskTitles.contains(task.title);

              return Container(
                margin: const EdgeInsets.only(bottom: AppStyles.s),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppStyles.radiusMedium,
                  border: Border.all(
                    color: isChecked 
                        ? AppColors.safe.withOpacity(0.4) 
                        : AppColors.surfaceCard.withOpacity(0.3),
                  ),
                ),
                child: ExpansionTile(
                  leading: Checkbox(
                    value: isChecked,
                    activeColor: AppColors.safe,
                    onChanged: (bool? val) {
                      setState(() {
                        if (val == true) {
                          _checkedTaskTitles.add(task.title);
                        } else {
                          _checkedTaskTitles.remove(task.title);
                        }
                      });
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      _buildBadge(task.category, AppColors.primaryLight),
                      const SizedBox(width: 6),
                      _buildBadge(
                        task.priorityLevel,
                        task.priorityLevel == 'Tinggi'
                            ? AppColors.critical
                            : task.priorityLevel == 'Sedang'
                                ? AppColors.warning
                                : AppColors.textMuted,
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: AppStyles.xl + AppStyles.s, right: AppStyles.m, bottom: AppStyles.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: AppColors.surfaceCard, height: 1),
                          const SizedBox(height: AppStyles.s),
                          Text(
                            task.recommendationText,
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
