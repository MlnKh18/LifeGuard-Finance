import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/anomaly_combined_record.dart';
import '../../domain/entities/monthly_expense_trend.dart';
import '../bloc/anomaly_cubit.dart';
import '../bloc/anomaly_state.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 2);
final _dateFormat = DateFormat('MMM dd, yyyy');

class ExpenseAnomalyPage extends StatelessWidget {
  const ExpenseAnomalyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnomalyCubit>(
      create: (context) => getIt<AnomalyCubit>()..loadAnomalies(),
      child: const ExpenseAnomalyView(),
    );
  }
}

class ExpenseAnomalyView extends StatelessWidget {
  const ExpenseAnomalyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Deteksi Anomali', style: AppTextStyles.heading1),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<AnomalyCubit, AnomalyState>(
        builder: (context, state) {
          if (state is AnomalyLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is AnomalyError) {
            return _buildErrorView(context, state.message);
          }

          if (state is AnomalyLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/daily-finance'),
        backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnomalyLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AnomalyCubit>().loadAnomalies(showLoading: false);
      },
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            'Monthly Expense Trends & Outliers',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildTrendChart(context, state),
          const SizedBox(height: 24),
          Text('Recent Transactions', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          if (state.recentCombinedRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text('Belum ada transaksi.'),
              ),
            )
          else
            ...state.recentCombinedRecords.map((record) => _buildTransactionCard(context, record)),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  void _showAnomalySelection(BuildContext context, AnomalyLoaded state) {
    final currentMonthAnomalies = state.recentCombinedRecords.where((record) {
      if (!record.isAnomaly) return false;
      final now = DateTime.now();
      final recordDate = record.record.recordDate;
      return recordDate.year == now.year && recordDate.month == now.month;
    }).toList();

    final targetList = currentMonthAnomalies.isNotEmpty 
        ? currentMonthAnomalies 
        : state.recentCombinedRecords.where((r) => r.isAnomaly).toList();

    if (targetList.isEmpty) return;

    if (targetList.length == 1) {
      context.push('/anomaly-detail', extra: targetList.first);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Anomali Terdeteksi', style: AppTextStyles.heading2),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: targetList.length,
              itemBuilder: (context, index) {
                final rec = targetList[index];
                final r = rec.record;
                final anomaly = rec.anomaly;
                
                final amountStr = _rupiahFormat.format(r.amount);
                final pctStr = anomaly != null ? anomaly.increasePercentage.toStringAsFixed(0) : '0';

                return ListTile(
                  leading: const Icon(Icons.warning_rounded, color: AppColors.riskCritical),
                  title: Text(r.category, style: AppTextStyles.heading3),
                  subtitle: Text(
                    'Nominal: $amountStr (Naik $pctStr%)',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    context.push('/anomaly-detail', extra: rec);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendChart(BuildContext context, AnomalyLoaded state) {
    final anomalyCount = state.anomalies.where((a) {
      final now = DateTime.now();
      return a.createdAt.year == now.year && a.createdAt.month == now.month;
    }).length;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expense', style: AppTextStyles.heading2),
                  Text('Volatility', style: AppTextStyles.heading2),
                  const SizedBox(height: 4),
                  Text('Last 6 Months', style: AppTextStyles.bodySmall),
                ],
              ),
              if (anomalyCount > 0)
                InkWell(
                  onTap: () => _showAnomalySelection(context, state),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.riskCriticalBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_rounded, color: AppColors.riskCritical, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$anomalyCount Anomali\nTerdeteksi',
                          style: AppTextStyles.label.copyWith(color: AppColors.riskCritical),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: _buildFlChart(state.monthlyTrend),
          ),
        ],
      ),
    );
  }

  Widget _buildFlChart(List<MonthlyExpenseTrend> trend) {
    if (trend.isEmpty) {
      return const Center(child: Text('Belum ada data historis.'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[i].totalAmount));
    }

    double maxY = trend.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1000;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index < 0 || index >= trend.length) return const SizedBox.shrink();
                final t = trend[index];
                final monthStr = DateFormat('MMM').format(t.month);
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    monthStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: t.isAnomaly ? AppColors.riskCritical : AppColors.textSecondary,
                      fontWeight: t.isAnomaly ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (trend.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryDark,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) {
                final index = spot.x.toInt();
                if (index < 0 || index >= trend.length) return false;
                return trend[index].isAnomaly;
              },
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppColors.riskCritical,
                  strokeWidth: 4,
                  strokeColor: AppColors.riskCritical.withValues(alpha: 0.3),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark.withValues(alpha: 0.2),
                  AppColors.primaryDark.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, AnomalyCombinedRecord record) {
    final bool isAnomaly = record.isAnomaly;
    final r = record.record;

    // Map category to icon
    IconData iconData = Icons.receipt_long;
    if (r.category.toLowerCase().contains('groceries')) iconData = Icons.shopping_cart;
    if (r.category.toLowerCase().contains('transport')) iconData = Icons.directions_car;
    if (r.category.toLowerCase().contains('dining') || r.category.toLowerCase().contains('food')) iconData = Icons.restaurant;
    if (r.category.toLowerCase().contains('electronic')) iconData = Icons.devices;

    return GestureDetector(
      onTap: () {
        if (isAnomaly) {
          context.push('/anomaly-detail', extra: record);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAnomaly ? AppColors.riskCritical : AppColors.border,
            width: isAnomaly ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.category, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(_dateFormat.format(r.recordDate), style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                _rupiahFormat.format(r.amount),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAnomaly ? AppColors.riskCritical : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
