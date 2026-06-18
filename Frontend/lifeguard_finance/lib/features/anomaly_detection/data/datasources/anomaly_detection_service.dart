import 'dart:math';
import '../../domain/entities/expense_transaction.dart';
import '../../domain/entities/monthly_expense_trend.dart';

class AnomalyDetectionService {
  const AnomalyDetectionService();

  static const double zThreshold = 1.5;

  /// Flags each transaction whose amount is a statistical outlier (|z-score| above
  /// [zThreshold]) relative to other transactions in the same category. Categories
  /// with fewer than 3 transactions are left unflagged — not enough samples for a
  /// meaningful local z-score.
  List<ExpenseTransaction> flagAnomalies(List<ExpenseTransaction> transactions) {
    final byCategory = <String, List<ExpenseTransaction>>{};
    for (final t in transactions) {
      byCategory.putIfAbsent(t.category, () => []).add(t);
    }

    final flagged = <ExpenseTransaction>[];
    for (final entry in byCategory.entries) {
      final group = entry.value;
      if (group.length < 3) {
        flagged.addAll(group);
        continue;
      }
      final amounts = group.map((t) => t.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final stdDev = _stdDev(amounts, mean);
      for (final t in group) {
        final z = stdDev == 0 ? 0.0 : (t.amount - mean) / stdDev;
        flagged.add(t.copyWith(isAnomaly: z.abs() > zThreshold, zScore: z));
      }
    }

    flagged.sort((a, b) => b.date.compareTo(a.date));
    return flagged;
  }

  /// Aggregates transactions into monthly totals and flags any month whose total is
  /// a statistical outlier (|z-score| above [zThreshold]) relative to the other months.
  List<MonthlyExpenseTrend> computeMonthlyTrend(List<ExpenseTransaction> transactions) {
    final byMonth = <DateTime, double>{};
    for (final t in transactions) {
      final key = DateTime(t.date.year, t.date.month);
      byMonth[key] = (byMonth[key] ?? 0) + t.amount;
    }

    final months = byMonth.keys.toList()..sort();
    if (months.isEmpty) return [];

    final totals = byMonth.values.toList();
    final mean = totals.reduce((a, b) => a + b) / totals.length;
    final stdDev = _stdDev(totals, mean);

    return months.map((month) {
      final total = byMonth[month]!;
      final z = stdDev == 0 ? 0.0 : (total - mean) / stdDev;
      return MonthlyExpenseTrend(
        month: month,
        totalAmount: total,
        isAnomaly: z.abs() > zThreshold,
        zScore: z,
      );
    }).toList();
  }

  double _stdDev(List<double> values, double mean) {
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }
}
