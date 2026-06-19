import 'dart:math';
import '../../domain/entities/anomaly_result.dart';
import '../../domain/entities/expense_transaction.dart';
import '../../domain/entities/monthly_expense_trend.dart';

class AnomalyDetectionService {
  const AnomalyDetectionService();

  /// Rule-based prototype detection (per project spec — not Isolation Forest):
  /// for each category, compare this month's total spend against the average
  /// of all prior months in that category. >30% increase = Anomali Ringan,
  /// >50% = Anomali Tinggi, otherwise Normal.
  List<AnomalyResult> analyzeCategories(List<ExpenseTransaction> transactions, {DateTime? referenceMonth}) {
    final now = referenceMonth ?? DateTime.now();

    final byCategory = <String, List<ExpenseTransaction>>{};
    for (final t in transactions) {
      byCategory.putIfAbsent(t.category, () => []).add(t);
    }

    final results = <AnomalyResult>[];
    for (final entry in byCategory.entries) {
      final category = entry.key;
      final currentMonthTxns = entry.value.where((t) => t.date.year == now.year && t.date.month == now.month);
      final historicalTxns = entry.value.where((t) => !(t.date.year == now.year && t.date.month == now.month));

      final currentAmount = currentMonthTxns.fold<double>(0, (sum, t) => sum + t.amount);
      if (currentAmount <= 0) continue; // nothing spent this month in this category

      final historicalByMonth = <DateTime, double>{};
      for (final t in historicalTxns) {
        final key = DateTime(t.date.year, t.date.month);
        historicalByMonth[key] = (historicalByMonth[key] ?? 0) + t.amount;
      }

      final historicalAverage = historicalByMonth.isEmpty
          ? currentAmount
          : historicalByMonth.values.reduce((a, b) => a + b) / historicalByMonth.length;

      final percentageIncrease =
          historicalAverage == 0 ? 0.0 : ((currentAmount - historicalAverage) / historicalAverage) * 100;

      final severity = _classify(percentageIncrease);

      results.add(AnomalyResult(
        category: category,
        historicalAverage: historicalAverage,
        currentAmount: currentAmount,
        percentageIncrease: percentageIncrease,
        severity: severity,
        estimatedFvsImpact: _estimateFvsImpact(severity),
        warningMessage: _warningMessage(category, severity, percentageIncrease),
      ));
    }

    results.sort((a, b) => b.percentageIncrease.compareTo(a.percentageIncrease));
    return results;
  }

  /// Stamps each transaction in the current month with the severity/percentage
  /// of its category's [AnomalyResult], so individual transaction tiles can be
  /// highlighted consistently with the category-level verdict.
  List<ExpenseTransaction> flagTransactions(List<ExpenseTransaction> transactions, List<AnomalyResult> categoryResults) {
    final now = DateTime.now();
    final resultByCategory = {for (final r in categoryResults) r.category: r};

    final flagged = transactions.map((t) {
      final isCurrentMonth = t.date.year == now.year && t.date.month == now.month;
      final result = resultByCategory[t.category];
      if (!isCurrentMonth || result == null) {
        return t.copyWith(severity: AnomalySeverity.normal, percentageIncrease: 0.0);
      }
      return t.copyWith(severity: result.severity, percentageIncrease: result.percentageIncrease);
    }).toList();

    flagged.sort((a, b) => b.date.compareTo(a.date));
    return flagged;
  }

  AnomalySeverity _classify(double percentageIncrease) {
    if (percentageIncrease > 50) return AnomalySeverity.tinggi;
    if (percentageIncrease > 30) return AnomalySeverity.ringan;
    return AnomalySeverity.normal;
  }

  double _estimateFvsImpact(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.tinggi:
        return -4.0;
      case AnomalySeverity.ringan:
        return -2.0;
      case AnomalySeverity.normal:
        return 0.0;
    }
  }

  String _warningMessage(String category, AnomalySeverity severity, double percentageIncrease) {
    final pct = percentageIncrease.toStringAsFixed(0);
    switch (severity) {
      case AnomalySeverity.tinggi:
        return 'Pengeluaran kategori $category naik $pct% dari rata-rata historis (Anomali Tinggi). Segera evaluasi pengeluaran ini.';
      case AnomalySeverity.ringan:
        return 'Pengeluaran kategori $category naik $pct% dari rata-rata historis (Anomali Ringan). Perlu diperhatikan.';
      case AnomalySeverity.normal:
        return 'Pengeluaran kategori $category masih dalam rentang normal.';
    }
  }

  /// Bonus visualization: aggregates transactions into monthly totals and flags
  /// any month whose total is a statistical outlier relative to other months.
  List<MonthlyExpenseTrend> computeMonthlyTrend(List<ExpenseTransaction> transactions) {
    const zThreshold = 1.5;
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
