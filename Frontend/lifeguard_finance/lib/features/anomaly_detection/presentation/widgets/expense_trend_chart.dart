import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/monthly_expense_trend.dart';

const _monthAbbr = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];

class ExpenseTrendChart extends StatelessWidget {
  final List<MonthlyExpenseTrend> trend;

  const ExpenseTrendChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[
      for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), trend[i].totalAmount),
    ];
    final maxY = trend.map((t) => t.totalAmount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [4, 4]),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= trend.length) return const SizedBox.shrink();
                  final month = trend[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _monthAbbr[month.month.month],
                      style: TextStyle(
                        fontSize: 10,
                        color: month.isAnomaly ? AppColors.riskCritical : AppColors.textSecondary,
                        fontWeight: month.isAnomaly ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withAlpha(26)),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isAnomaly = trend[index].isAnomaly;
                  return FlDotCirclePainter(
                    radius: isAnomaly ? 6 : 3,
                    color: isAnomaly ? AppColors.riskCritical : AppColors.primary,
                    strokeWidth: 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
