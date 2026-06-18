import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../daily_finance/presentation/bloc/daily_finance_cubit.dart';
import '../../../daily_finance/presentation/bloc/daily_finance_state.dart';
import '../../domain/entities/early_warning.dart';

class EarlyWarningPage extends StatefulWidget {
  const EarlyWarningPage({super.key});

  @override
  State<EarlyWarningPage> createState() => _EarlyWarningPageState();
}

class _EarlyWarningPageState extends State<EarlyWarningPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DailyFinanceCubit>().loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Peringatan Risiko', style: AppTextStyles.heading2),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Belum Dibaca'),
            Tab(text: 'Semua Peringatan'),
          ],
        ),
      ),
      body: BlocBuilder<DailyFinanceCubit, DailyFinanceState>(
        builder: (context, state) {
          if (state is DailyFinanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailyFinanceLoaded) {
            final unreadWarnings = state.latestWarnings;
            // For now, let's display what we have.

            return TabBarView(
              controller: _tabController,
              children: [
                _buildWarningList(unreadWarnings, true),
                _buildWarningList(state.allWarnings, false),
              ],
            );
          }

          return const Center(child: Text('Gagal memuat peringatan.'));
        },
      ),
    );
  }

  Widget _buildWarningList(List<EarlyWarning> warnings, bool isUnreadTab) {
    if (warnings.isEmpty) {
      return Center(
        child: Text(
          'Belum ada peringatan risiko.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    // Sort newest first
    warnings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: warnings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final warning = warnings[index];
        return _WarningCard(
          warning: warning,
          onMarkRead: warning.isRead
              ? null
              : () {
                  context.read<DailyFinanceCubit>().markWarningAsRead(warning.warningId);
                },
        );
      },
    );
  }
}

class _WarningCard extends StatelessWidget {
  final EarlyWarning warning;
  final VoidCallback? onMarkRead;

  const _WarningCard({
    required this.warning,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    IconData severityIcon;

    switch (warning.severity) {
      case EarlyWarningSeverity.high:
        severityColor = AppColors.riskCritical;
        severityIcon = Icons.error_rounded;
        break;
      case EarlyWarningSeverity.medium:
        severityColor = AppColors.riskWarning;
        severityIcon = Icons.warning_amber_rounded;
        break;
      case EarlyWarningSeverity.low:
        severityColor = AppColors.secondary;
        severityIcon = Icons.info_outline_rounded;
        break;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(severityIcon, color: severityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warning.title,
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(warning.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!warning.isRead && onMarkRead != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                  onPressed: onMarkRead,
                  tooltip: 'Tandai sudah dibaca',
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            warning.message,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
