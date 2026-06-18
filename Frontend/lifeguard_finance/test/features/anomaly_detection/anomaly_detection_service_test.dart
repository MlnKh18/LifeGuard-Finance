import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/anomaly_detection/data/datasources/anomaly_detection_service.dart';
import 'package:lifeguard_finance/features/anomaly_detection/domain/entities/expense_transaction.dart';

void main() {
  const service = AnomalyDetectionService();

  ExpenseTransaction txn(String category, double amount, DateTime date) {
    return ExpenseTransaction(id: '$category-${date.toIso8601String()}', category: category, amount: amount, date: date);
  }

  group('AnomalyDetectionService.analyzeCategories', () {
    test('flags a category that rose more than 50% as Anomali Tinggi', () {
      final now = DateTime(2026, 6, 15);
      final transactions = [
        txn('Makanan', 1000000, DateTime(2026, 4, 10)),
        txn('Makanan', 1000000, DateTime(2026, 5, 10)),
        txn('Makanan', 1600000, now), // +60% vs historical average of 1,000,000
      ];

      final results = service.analyzeCategories(transactions, referenceMonth: now);
      final makanan = results.firstWhere((r) => r.category == 'Makanan');

      expect(makanan.severity, AnomalySeverity.tinggi);
      expect(makanan.percentageIncrease, closeTo(60, 0.01));
      expect(makanan.estimatedFvsImpact, lessThan(0));
    });

    test('flags a category that rose between 30% and 50% as Anomali Ringan', () {
      final now = DateTime(2026, 6, 15);
      final transactions = [
        txn('Hiburan', 1000000, DateTime(2026, 5, 10)),
        txn('Hiburan', 1350000, now), // +35%
      ];

      final results = service.analyzeCategories(transactions, referenceMonth: now);
      final hiburan = results.firstWhere((r) => r.category == 'Hiburan');

      expect(hiburan.severity, AnomalySeverity.ringan);
    });

    test('keeps a category within 30% of its historical average as Normal', () {
      final now = DateTime(2026, 6, 15);
      final transactions = [
        txn('Transportasi', 500000, DateTime(2026, 5, 10)),
        txn('Transportasi', 520000, now), // +4%
      ];

      final results = service.analyzeCategories(transactions, referenceMonth: now);
      final transportasi = results.firstWhere((r) => r.category == 'Transportasi');

      expect(transportasi.severity, AnomalySeverity.normal);
      expect(transportasi.estimatedFvsImpact, 0);
    });

    test('skips categories with no spending in the reference month', () {
      final now = DateTime(2026, 6, 15);
      final transactions = [
        txn('Kesehatan', 300000, DateTime(2026, 3, 10)),
      ];

      final results = service.analyzeCategories(transactions, referenceMonth: now);

      expect(results.where((r) => r.category == 'Kesehatan'), isEmpty);
    });

    test('treats a category with no history as its own baseline (Normal)', () {
      final now = DateTime(2026, 6, 15);
      final transactions = [txn('Pendidikan', 750000, now)];

      final results = service.analyzeCategories(transactions, referenceMonth: now);
      final pendidikan = results.firstWhere((r) => r.category == 'Pendidikan');

      expect(pendidikan.severity, AnomalySeverity.normal);
      expect(pendidikan.historicalAverage, 750000);
    });
  });

  group('AnomalyDetectionService.flagTransactions', () {
    test('stamps current-month transactions with their category severity', () {
      final now = DateTime(2026, 6, 15);
      final transactions = [
        txn('Makanan', 1000000, DateTime(2026, 5, 10)),
        txn('Makanan', 1600000, now),
      ];
      final results = service.analyzeCategories(transactions, referenceMonth: now);
      final flagged = service.flagTransactions(transactions, results);

      final current = flagged.firstWhere((t) => t.date == now);
      expect(current.severity, AnomalySeverity.tinggi);
      expect(current.isAnomaly, isTrue);
    });
  });
}
