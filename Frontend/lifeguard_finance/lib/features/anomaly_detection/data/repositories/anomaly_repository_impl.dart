import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../daily_finance/domain/entities/finance_record_entity.dart';
import '../../../daily_finance/domain/repositories/finance_record_repository.dart';
import '../../domain/entities/anomaly_result.dart';
import '../../domain/entities/anomaly_combined_record.dart';
import '../../domain/entities/monthly_expense_trend.dart';
import '../../domain/repositories/anomaly_repository.dart';

import '../../../../core/network/api_client.dart';

class AnomalyRepositoryImpl implements AnomalyRepository {
  final HiveService hiveService;
  final FinanceRecordRepository financeRecordRepository;
  final AuthRepository authRepository;
  final ApiClient apiClient;

  AnomalyRepositoryImpl({
    required this.hiveService,
    required this.financeRecordRepository,
    required this.authRepository,
    required this.apiClient,
  });

  static const String _anomalyKey = LocalKeys.anomalyResults;

  @override
  Future<AnomalyResult?> detectForExpense(FinanceRecord expense) async {
    if (expense.type != FinanceRecordType.expense) return null;

    debugPrint('================ ANOMALY DETECTION START ================');
    debugPrint('Expense category: ${expense.category}');
    debugPrint('Current amount: ${expense.amount}');

    // 1. Ambil expense records
    final allRecords = await financeRecordRepository.getExpenseRecords();

    // 2 & 3. Filter familyId sama, category sama
    // 4. Filter records sebelum tanggal current expense
    // 5. Ambil 3-6 bulan terakhir. Let's take up to 6 months before the expense date.
    final sixMonthsAgo = expense.recordDate.subtract(const Duration(days: 180));
    
    final historicalRecords = allRecords.where((r) {
      return r.familyId == expense.familyId &&
             r.category == expense.category &&
             r.recordId != expense.recordId && // exclude current
             r.recordDate.isBefore(expense.recordDate) &&
             r.recordDate.isAfter(sixMonthsAgo);
    }).toList();

    debugPrint('Historical records count: ${historicalRecords.length}');

    if (historicalRecords.length < 3) {
      debugPrint('Data belum cukup untuk mendeteksi pola anomali.');
      debugPrint('================ ANOMALY DETECTION END ================');
      return null;
    }

    // 6. Hitung averageAmount
    double totalHistoricalAmount = 0;
    for (var r in historicalRecords) {
      totalHistoricalAmount += r.amount;
    }
    final averageAmount = totalHistoricalAmount / historicalRecords.length;

    debugPrint('Average amount: $averageAmount');

    if (averageAmount <= 0) {
      debugPrint('================ ANOMALY DETECTION END ================');
      return null;
    }

    // 7. Hitung increasePercentage
    final increasePercentage = ((expense.amount - averageAmount) / averageAmount) * 100;
    debugPrint('Increase percentage: $increasePercentage');

    // 8. Tentukan status
    AnomalyStatus status = AnomalyStatus.normal;
    if (increasePercentage > 50) {
      status = AnomalyStatus.highAnomaly;
    } else if (increasePercentage > 30) {
      status = AnomalyStatus.lightAnomaly;
    }

    debugPrint('Anomaly status: $status');
    debugPrint('================ ANOMALY DETECTION END ================');

    // 9. Simpan AnomalyResult jika light/high anomaly
    if (status != AnomalyStatus.normal) {
      String message = 'Pengeluaran kategori ${expense.category} naik ${increasePercentage.toStringAsFixed(0)}% dibanding rata-rata historis. Periksa kembali pola belanja minggu atau bulan ini.';
      if (status == AnomalyStatus.highAnomaly) {
        message = 'Pengeluaran tidak normal terdeteksi pada kategori ${expense.category}. Kenaikan mencapai ${increasePercentage.toStringAsFixed(0)}% dari rata-rata historis.';
      }

      final result = AnomalyResult(
        anomalyId: const Uuid().v4(),
        familyId: expense.familyId,
        userId: expense.userId,
        userEmail: expense.userEmail,
        recordId: expense.recordId,
        category: expense.category,
        currentAmount: expense.amount,
        averageAmount: averageAmount,
        increasePercentage: increasePercentage,
        status: status,
        message: message,
        createdAt: DateTime.now(),
      );

      final anomalies = await getAnomalyResults();
      anomalies.add(result);
      
      final jsonList = anomalies.map((a) => a.toJson()).toList();
      await hiveService.saveData(_anomalyKey, jsonList);

      // Sync to API
      try {
        await apiClient.dio.post('/anomalies', data: {
          'category': result.category,
          'currentAmount': result.currentAmount,
          'averageAmount': result.averageAmount,
          'increasePercentage': result.increasePercentage,
          'status': result.status.name,
          'message': result.message,
        });
      } catch (e) {
        // debugPrint('Anomaly API Sync Error: $e');
      }

      return result;
    }

    return null;
  }

  @override
  Future<List<AnomalyResult>> getAnomalyResults() async {
    // API sync is temporarily disabled to prevent UI connection timeouts.
    // Anomalies are written to Hive during detectForExpense.
    final rawData = hiveService.getData(_anomalyKey);
    if (rawData == null) return [];
    
    final rawList = rawData is List ? rawData : <dynamic>[];
    return rawList.map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      return AnomalyResult.fromJson(json);
    }).toList();
  }

  @override
  Future<List<AnomalyResult>> getLatestAnomalies() async {
    final anomalies = await getAnomalyResults();
    anomalies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return anomalies;
  }

  @override
  Future<List<AnomalyCombinedRecord>> getRecentCombinedRecords() async {
    // 1. Get recent expenses
    final allExpenses = await financeRecordRepository.getExpenseRecords();
    
    // Sort descending by date
    allExpenses.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    final recentExpenses = allExpenses.take(50).toList(); // Last 50

    // 2. Get anomalies
    final allAnomalies = await getAnomalyResults();
    final Map<String, AnomalyResult> anomalyMap = {
      for (var a in allAnomalies) a.recordId: a
    };

    // 3. Combine
    return recentExpenses.map((expense) {
      return AnomalyCombinedRecord(
        record: expense,
        anomaly: anomalyMap[expense.recordId],
      );
    }).toList();
  }

  @override
  Future<List<MonthlyExpenseTrend>> getMonthlyTrend() async {
    final allExpenses = await financeRecordRepository.getExpenseRecords();
    
    final byMonth = <DateTime, double>{};
    for (final t in allExpenses) {
      final key = DateTime(t.recordDate.year, t.recordDate.month);
      byMonth[key] = (byMonth[key] ?? 0) + t.amount;
    }

    final months = byMonth.keys.toList()..sort();
    if (months.isEmpty) return [];

    // Filter to last 6 months
    final last6Months = months.length > 6 ? months.sublist(months.length - 6) : months;

    // We will flag a month as anomaly if it has any AnomalyResult in that month
    final allAnomalies = await getAnomalyResults();

    return last6Months.map((month) {
      final total = byMonth[month]!;
      
      // Check if there's any anomaly in this month
      final hasAnomaly = allAnomalies.any((a) {
        final r = allExpenses.firstWhere((e) => e.recordId == a.recordId, orElse: () => allExpenses.first);
        return r.recordDate.year == month.year && r.recordDate.month == month.month;
      });

      return MonthlyExpenseTrend(
        month: month,
        totalAmount: total,
        isAnomaly: hasAnomaly,
        zScore: 0.0, // Not used anymore, keep 0
      );
    }).toList();
  }
}
