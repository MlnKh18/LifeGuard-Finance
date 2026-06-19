import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/anomaly_detection/domain/entities/expense_transaction.dart';
import 'package:lifeguard_finance/features/anomaly_detection/data/datasources/anomaly_detection_service.dart';
import 'package:lifeguard_finance/features/anomaly_detection/domain/entities/anomaly_result.dart';

void main() {
  late AnomalyDetectionService service;

  setUp(() {
    service = const AnomalyDetectionService();
  });

  group('AnomalyDetectionService Tests', () {
    test('Should detect anomaly using rule-based detection', () {
      final now = DateTime.now();
      final records = [
        ExpenseTransaction(id: '1', date: now.subtract(const Duration(days: 7)), category: 'Food', amount: 50000),
        ExpenseTransaction(id: '2', date: now.subtract(const Duration(days: 14)), category: 'Food', amount: 50000),
        ExpenseTransaction(id: '3', date: now.subtract(const Duration(days: 21)), category: 'Food', amount: 50000),
        ExpenseTransaction(id: '4', date: now, category: 'Food', amount: 300000),
      ];

      final anomalies = service.analyzeCategories(records, referenceMonth: now);

      expect(anomalies.isNotEmpty, true);
      expect(anomalies.first.severity, AnomalySeverity.tinggi);
    });

    test('Should not detect anomalies in normal data', () {
      final now = DateTime.now();
      final records = [
        ExpenseTransaction(id: '1', date: now.subtract(const Duration(days: 7)), category: 'Transport', amount: 20000),
        ExpenseTransaction(id: '2', date: now.subtract(const Duration(days: 14)), category: 'Transport', amount: 20000),
        ExpenseTransaction(id: '3', date: now.subtract(const Duration(days: 21)), category: 'Transport', amount: 20000),
        ExpenseTransaction(id: '4', date: now, category: 'Transport', amount: 21000),
      ];

      final anomalies = service.analyzeCategories(records, referenceMonth: now);

      expect(anomalies.isEmpty, true);
    });
  });
}
