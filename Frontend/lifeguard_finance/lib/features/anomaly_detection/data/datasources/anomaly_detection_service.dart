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
    final currentWeekStart = now.subtract(const Duration(days: 7));

    final currentWeekTotals = <int, double>{}; 
    final historicalTotals = <int, List<double>>{};

    final dailyAmounts = <String, double>{};
    final dailyDates = <String, DateTime>{};

    for (final t in transactions) {
      final key = '${t.date.year}-${t.date.month}-${t.date.day}';
      dailyAmounts[key] = (dailyAmounts[key] ?? 0) + t.amount;
      dailyDates[key] = DateTime(t.date.year, t.date.month, t.date.day);
    }

    for (final entry in dailyAmounts.entries) {
      final date = dailyDates[entry.key]!;
      final amount = entry.value;
      
      if (date.isAfter(currentWeekStart) || date.isAtSameMomentAs(currentWeekStart)) {
        currentWeekTotals[date.weekday] = amount;
      } else {
        historicalTotals.putIfAbsent(date.weekday, () => []).add(amount);
      }
    }

    final results = <AnomalyResult>[];
    final dayNames = {
      DateTime.monday: 'Senin',
      DateTime.tuesday: 'Selasa',
      DateTime.wednesday: 'Rabu',
      DateTime.thursday: 'Kamis',
      DateTime.friday: 'Jumat',
      DateTime.saturday: 'Sabtu',
      DateTime.sunday: 'Minggu',
    };

    for (final entry in currentWeekTotals.entries) {
      final weekday = entry.key;
      final currentAmount = entry.value;
      final historicals = historicalTotals[weekday] ?? [];

      if (historicals.isEmpty) continue;

      final historicalAverage = historicals.reduce((a, b) => a + b) / historicals.length;
      if (historicalAverage == 0) continue;

      final percentageIncrease = ((currentAmount - historicalAverage) / historicalAverage) * 100;
      final severity = _classify(percentageIncrease);

      if (severity != AnomalySeverity.normal) {
        final dayName = dayNames[weekday] ?? '';
        results.add(AnomalyResult(
          category: dayName,
          historicalAverage: historicalAverage,
          currentAmount: currentAmount,
          percentageIncrease: percentageIncrease,
          severity: severity,
          estimatedFvsImpact: _estimateFvsImpact(severity),
          warningMessage: 'Pengeluaran hari $dayName ini naik ${percentageIncrease.toStringAsFixed(0)}% dari rata-rata hari $dayName biasanya.',
        ));
      }
    }

    results.sort((a, b) => b.percentageIncrease.compareTo(a.percentageIncrease));
    return results;
  }

  List<ExpenseTransaction> flagTransactions(List<ExpenseTransaction> transactions, List<AnomalyResult> categoryResults) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(const Duration(days: 7));
    final resultByDay = {for (final r in categoryResults) r.category: r};
    
    final dayNames = {
      DateTime.monday: 'Senin',
      DateTime.tuesday: 'Selasa',
      DateTime.wednesday: 'Rabu',
      DateTime.thursday: 'Kamis',
      DateTime.friday: 'Jumat',
      DateTime.saturday: 'Sabtu',
      DateTime.sunday: 'Minggu',
    };

    final flagged = transactions.map((t) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      final isCurrentWeek = date.isAfter(currentWeekStart) || date.isAtSameMomentAs(currentWeekStart);
      final dayName = dayNames[t.date.weekday];
      final result = resultByDay[dayName];
      
      if (!isCurrentWeek || result == null) {
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
