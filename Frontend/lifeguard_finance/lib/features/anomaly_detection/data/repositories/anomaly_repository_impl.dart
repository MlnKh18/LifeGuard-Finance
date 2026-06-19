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

class AnomalyRepositoryImpl implements AnomalyRepository {
  final HiveService hiveService;
  final FinanceRecordRepository financeRecordRepository;
  final AuthRepository authRepository;

  AnomalyRepositoryImpl({
    required this.hiveService,
    required this.financeRecordRepository,
    required this.authRepository,
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

      return result;
    }

    return null;
  }

  Future<void> _checkAndSeed() async {
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();
    final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';

    final allExpenses = await financeRecordRepository.getExpenseRecords();
    final hasDummy = allExpenses.any(
      (r) => r.familyId == currentFamilyId && r.recordId.startsWith('dummy_'),
    );
    if (!hasDummy) {
      await _seedDummyData();
    }
  }

  Future<void> _seedDummyData() async {
    debugPrint('================ SEEDING ANOMALY DUMMY DATA ================');
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();
    final String currentUserId = currentUser?.userId ?? 'dummy_user_id';
    final String currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? 'dummy_family_id';
    final String currentEmail = currentUser?.email ?? 'family@lifeguard.com';

    final now = DateTime.now();
    DateTime getPastMonthDate(int monthsAgo, int day) {
      return DateTime(now.year, now.month - monthsAgo, day);
    }

    final dummyRecords = <FinanceRecord>[];
    
    // Food expenses (normal, around Rp 3M)
    for (int i = 5; i >= 0; i--) {
      dummyRecords.add(FinanceRecord(
        recordId: 'dummy_food_$i',
        familyId: currentFamilyId,
        userId: currentUserId,
        userEmail: currentEmail,
        type: FinanceRecordType.expense,
        category: 'food',
        amount: 3000000.0 + (i % 2 == 0 ? 150000 : -100000),
        recordDate: getPastMonthDate(i, 10),
        notes: 'Belanja bulanan sembako',
        createdAt: getPastMonthDate(i, 10),
        updatedAt: getPastMonthDate(i, 10),
      ));
    }

    // Transportation expenses (normal, around Rp 800k)
    for (int i = 5; i >= 0; i--) {
      dummyRecords.add(FinanceRecord(
        recordId: 'dummy_trans_$i',
        familyId: currentFamilyId,
        userId: currentUserId,
        userEmail: currentEmail,
        type: FinanceRecordType.expense,
        category: 'transportation',
        amount: 800000.0 + (i % 3 == 0 ? 50000 : -30000),
        recordDate: getPastMonthDate(i, 15),
        notes: 'Bensin & tol bulanan',
        createdAt: getPastMonthDate(i, 15),
        updatedAt: getPastMonthDate(i, 15),
      ));
    }

    // Utilities expenses (normal, around Rp 1.2M)
    for (int i = 5; i >= 0; i--) {
      dummyRecords.add(FinanceRecord(
        recordId: 'dummy_util_$i',
        familyId: currentFamilyId,
        userId: currentUserId,
        userEmail: currentEmail,
        type: FinanceRecordType.expense,
        category: 'utilities',
        amount: 1200000.0 + (i % 2 == 0 ? -80000 : 60000),
        recordDate: getPastMonthDate(i, 5),
        notes: 'Listrik, air & internet',
        createdAt: getPastMonthDate(i, 5),
        updatedAt: getPastMonthDate(i, 5),
      ));
    }

    // Entertainment expenses (normal Rp 500k, Anomaly Rp 4.5M in month 2)
    for (int i = 5; i >= 0; i--) {
      final isAnomaly = (i == 2);
      dummyRecords.add(FinanceRecord(
        recordId: 'dummy_ent_$i',
        familyId: currentFamilyId,
        userId: currentUserId,
        userEmail: currentEmail,
        type: FinanceRecordType.expense,
        category: 'entertainment',
        amount: isAnomaly ? 4500000.0 : 500000.0 + (i % 2 == 0 ? 50000 : -20000),
        recordDate: getPastMonthDate(i, 20),
        notes: isAnomaly ? 'Pembelian konsol game & aksesoris' : 'Nonton bioskop & kafe akhir pekan',
        createdAt: getPastMonthDate(i, 20),
        updatedAt: getPastMonthDate(i, 20),
      ));
    }

    // Health expenses (normal Rp 400k, Anomaly Rp 8.0M in current month)
    for (int i = 5; i >= 0; i--) {
      final isAnomaly = (i == 0);
      dummyRecords.add(FinanceRecord(
        recordId: 'dummy_health_$i',
        familyId: currentFamilyId,
        userId: currentUserId,
        userEmail: currentEmail,
        type: FinanceRecordType.expense,
        category: 'health',
        amount: isAnomaly ? 8000000.0 : 400000.0 + (i % 3 == 0 ? 30000 : -10000),
        recordDate: getPastMonthDate(i, 18),
        notes: isAnomaly ? 'Tindakan medis IGD & obat rawat jalan' : 'Vitamin & obat rutin',
        createdAt: getPastMonthDate(i, 18),
        updatedAt: getPastMonthDate(i, 18),
      ));
    }

    // Save all finance records
    final existingRaw = hiveService.getData(LocalKeys.financeRecords);
    final existingList = existingRaw is List ? existingRaw : <dynamic>[];
    final updatedList = [...existingList, ...dummyRecords.map((r) => r.toJson())];
    await hiveService.saveData(LocalKeys.financeRecords, updatedList);

    // Save anomaly results
    final dummyAnomalies = <AnomalyResult>[];
    
    // Anomaly 1: Entertainment in April
    dummyAnomalies.add(AnomalyResult(
      anomalyId: 'dummy_anomaly_ent',
      familyId: currentFamilyId,
      userId: currentUserId,
      userEmail: currentEmail,
      recordId: 'dummy_ent_2',
      category: 'entertainment',
      currentAmount: 4500000.0,
      averageAmount: 500000.0,
      increasePercentage: 800.0,
      status: AnomalyStatus.highAnomaly,
      message: 'Pengeluaran tidak normal terdeteksi pada kategori entertainment. Kenaikan mencapai 800% dari rata-rata historis Rp 500.000.',
      createdAt: getPastMonthDate(2, 20),
    ));

    // Anomaly 2: Health in current month
    dummyAnomalies.add(AnomalyResult(
      anomalyId: 'dummy_anomaly_health',
      familyId: currentFamilyId,
      userId: currentUserId,
      userEmail: currentEmail,
      recordId: 'dummy_health_0',
      category: 'health',
      currentAmount: 8000000.0,
      averageAmount: 400000.0,
      increasePercentage: 1900.0,
      status: AnomalyStatus.highAnomaly,
      message: 'Pengeluaran tidak normal terdeteksi pada kategori health. Kenaikan mencapai 1900% dari rata-rata historis Rp 400.000.',
      createdAt: getPastMonthDate(0, 18),
    ));

    final existingAnomRaw = hiveService.getData(LocalKeys.anomalyResults);
    final existingAnomList = existingAnomRaw is List ? existingAnomRaw : <dynamic>[];
    final updatedAnomList = [...existingAnomList, ...dummyAnomalies.map((a) => a.toJson())];
    await hiveService.saveData(LocalKeys.anomalyResults, updatedAnomList);
    
    debugPrint('================ DUMMY DATA SEED COMPLETE ================');
  }

  @override
  Future<List<AnomalyResult>> getAnomalyResults() async {
    await _checkAndSeed();
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
    await _checkAndSeed();
    final anomalies = await getAnomalyResults();
    anomalies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return anomalies;
  }

  @override
  Future<List<AnomalyCombinedRecord>> getRecentCombinedRecords() async {
    await _checkAndSeed();
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
    await _checkAndSeed();
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
