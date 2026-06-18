import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/finance_record_entity.dart';
import '../bloc/daily_finance_cubit.dart';
import '../bloc/daily_finance_state.dart';
import '../widgets/daily_finance_modals.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final _dateFormat = DateFormat('dd MMM yyyy');

class DailyFinancePage extends StatelessWidget {
  const DailyFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DailyFinanceCubit>(
      create: (context) => getIt<DailyFinanceCubit>()..loadRecords(),
      child: const DailyFinanceView(),
    );
  }
}

class DailyFinanceView extends StatelessWidget {
  const DailyFinanceView({super.key});

  void _showAddRecordDialog(BuildContext context, FinanceRecordType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<DailyFinanceCubit>(),
        child: AddFinanceRecordForm(
          type: type,
          onSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Catatan berhasil ditambahkan'), backgroundColor: AppColors.riskSafe),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Harian', style: AppTextStyles.heading3),
      ),
      body: BlocConsumer<DailyFinanceCubit, DailyFinanceState>(
        listener: (context, state) {
          if (state is DailyFinanceActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.riskSafe),
            );
          } else if (state is DailyFinanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.riskCritical),
            );
          }
        },
        builder: (context, state) {
          if (state is DailyFinanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailyFinanceLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<DailyFinanceCubit>().loadRecords(showLoading: false),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummaryCard(context, state),
                          const SizedBox(height: 16),
                          _buildActionButtons(context),
                          const SizedBox(height: 24),
                          _buildWarningSection(context, state),
                          const SizedBox(height: 24),
                          _buildFilterChips(context, state.filter),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: _buildTransactionList(state.records),
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

  Widget _buildSummaryCard(BuildContext context, DailyFinanceLoaded state) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Hari Ini', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pemasukan', style: AppTextStyles.bodyMedium),
              Text(_rupiahFormat.format(state.totalIncomeToday), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.riskSafe)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pengeluaran', style: AppTextStyles.bodyMedium),
              Text(_rupiahFormat.format(state.totalExpenseToday), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.riskCritical)),
            ],
          ),
          const Divider(height: 24),
          Text('Ringkasan Bulan Ini', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pemasukan', style: AppTextStyles.bodyMedium),
              Text(_rupiahFormat.format(state.totalIncomeThisMonth), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.riskSafe)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pengeluaran', style: AppTextStyles.bodyMedium),
              Text(_rupiahFormat.format(state.totalExpenseThisMonth), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.riskCritical)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cashflow', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text(
                _rupiahFormat.format(state.monthlyCashflow), 
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: state.monthlyCashflow >= 0 ? AppColors.riskSafe : AppColors.riskCritical,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showAddRecordDialog(context, FinanceRecordType.income),
            icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 18),
            label: const Text('Pemasukan', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.riskSafe,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showAddRecordDialog(context, FinanceRecordType.expense),
            icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
            label: const Text('Pengeluaran', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.riskCritical,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningSection(BuildContext context, DailyFinanceLoaded state) {
    if (state.latestWarnings.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.riskSafe, size: 32),
            const SizedBox(height: 8),
            Text(
              'Belum ada peringatan risiko dari catatan harian.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final warning = state.latestWarnings.first;
    Color severityColor = AppColors.riskCritical;
    IconData severityIcon = Icons.error_rounded;

    // Severity mapping (assuming we know the string representation)
    if (warning.severity.name == 'medium') {
      severityColor = AppColors.riskWarning;
      severityIcon = Icons.warning_amber_rounded;
    } else if (warning.severity.name == 'low') {
      severityColor = AppColors.secondary;
      severityIcon = Icons.info_outline_rounded;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(severityIcon, color: severityColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warning.title,
                  style: AppTextStyles.heading3.copyWith(color: severityColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Early Warning Page? We can just leave it as mark read for now
                  context.read<DailyFinanceCubit>().markWarningAsRead(warning.warningId);
                },
                child: const Text('Tandai Dibaca'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(warning.message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, String currentFilter) {
    final filters = ['Semua', 'Pendapatan', 'Pengeluaran', 'Hari ini', 'Minggu ini', 'Bulan ini'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = currentFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (_) {
                context.read<DailyFinanceCubit>().applyFilter(f);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(List<FinanceRecord> records) {
    if (records.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text('Belum ada catatan keuangan.'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final record = records[index];
          final isIncome = record.type == FinanceRecordType.income;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isIncome ? AppColors.riskSafe.withValues(alpha: 0.2) : AppColors.riskCritical.withValues(alpha: 0.2),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? AppColors.riskSafe : AppColors.riskCritical,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.category, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      if (record.notes != null)
                        Text(record.notes!, style: AppTextStyles.dataLabel),
                      Text('${_dateFormat.format(record.recordDate)} • ${record.userEmail}', style: AppTextStyles.dataLabel.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                Text(
                  _rupiahFormat.format(record.amount),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? AppColors.riskSafe : AppColors.riskCritical,
                  ),
                ),
              ],
            ),
          );
        },
        childCount: records.length,
      ),
    );
  }
}
