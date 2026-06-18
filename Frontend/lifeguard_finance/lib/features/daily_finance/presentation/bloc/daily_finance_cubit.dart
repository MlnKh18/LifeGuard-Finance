import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/finance_record_entity.dart';
import '../../domain/repositories/finance_record_repository.dart';
import '../../../anomaly_detection/domain/repositories/anomaly_repository.dart';
import '../../../early_warning/domain/repositories/early_warning_repository.dart';
import '../../../early_warning/domain/entities/early_warning.dart';
import 'daily_finance_state.dart';
import 'package:uuid/uuid.dart';

class DailyFinanceCubit extends Cubit<DailyFinanceState> {
  final FinanceRecordRepository repository;
  final AnomalyRepository anomalyRepository;
  final EarlyWarningRepository earlyWarningRepository;
  final AuthRepository authRepository;
  final HiveService hiveService;
  StreamSubscription? _profileSubscription;
  StreamSubscription? _recordsSubscription;
  StreamSubscription? _warningsSubscription;

  DailyFinanceCubit({
    required this.repository,
    required this.anomalyRepository,
    required this.earlyWarningRepository,
    required this.authRepository,
    required this.hiveService,
  }) : super(DailyFinanceInitial()) {
    _profileSubscription = hiveService.watchKey(LocalKeys.familyProfile).listen((_) {
      loadRecords(showLoading: false);
    });
    _recordsSubscription = hiveService.watchKey(LocalKeys.financeRecords).listen((_) {
      loadRecords(showLoading: false);
    });
    _warningsSubscription = hiveService.watchKey(LocalKeys.earlyWarnings).listen((_) {
      loadRecords(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _recordsSubscription?.cancel();
    _warningsSubscription?.cancel();
    return super.close();
  }

  String _currentFilter = 'Semua';

  Future<void> loadRecords({String? filter, bool showLoading = true}) async {
    if (showLoading) {
      emit(DailyFinanceLoading());
    }
    try {
      if (filter != null) {
        _currentFilter = filter;
      }

      final session = await authRepository.getCurrentSession();
      final currentUser = await authRepository.getCurrentUser();
      final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';

      final rawRecords = await repository.getRecords();
      final allRecords = rawRecords.where((r) => r.familyId == currentFamilyId).toList();
      final now = DateTime.now();
      
      // Calculate Summaries
      final incomeRecords = allRecords.where((r) => r.type == FinanceRecordType.income).toList();
      final expenseRecords = allRecords.where((r) => r.type == FinanceRecordType.expense).toList();

      double totalIncomeToday = 0;
      double totalExpenseToday = 0;
      double totalIncomeThisMonth = 0;
      double totalExpenseThisMonth = 0;

      for (var record in allRecords) {
        bool isToday = record.recordDate.year == now.year &&
            record.recordDate.month == now.month &&
            record.recordDate.day == now.day;
            
        bool isThisMonth = record.recordDate.year == now.year &&
            record.recordDate.month == now.month;

        if (record.type == FinanceRecordType.income) {
          if (isToday) totalIncomeToday += record.amount;
          if (isThisMonth) totalIncomeThisMonth += record.amount;
        } else if (record.type == FinanceRecordType.expense) {
          if (isToday) totalExpenseToday += record.amount;
          if (isThisMonth) totalExpenseThisMonth += record.amount;
        }
      }

      // Filter list based on _currentFilter
      List<FinanceRecord> filteredRecords = allRecords;
      if (_currentFilter == 'Pendapatan') {
        filteredRecords = incomeRecords;
      } else if (_currentFilter == 'Pengeluaran') {
        filteredRecords = expenseRecords;
      } else if (_currentFilter == 'Hari ini') {
        filteredRecords = allRecords.where((r) => 
            r.recordDate.year == now.year && 
            r.recordDate.month == now.month && 
            r.recordDate.day == now.day).toList();
      } else if (_currentFilter == 'Minggu ini') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        filteredRecords = allRecords.where((r) => 
            r.recordDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
            r.recordDate.isBefore(now.add(const Duration(days: 1)))).toList();
      } else if (_currentFilter == 'Bulan ini') {
        filteredRecords = allRecords.where((r) => 
            r.recordDate.year == now.year && 
            r.recordDate.month == now.month).toList();
      }

      // Sort by date descending
      filteredRecords.sort((a, b) => b.recordDate.compareTo(a.recordDate));

      final rawWarnings = await earlyWarningRepository.getUnreadWarnings();
      final warnings = rawWarnings.where((w) => w.familyId == currentFamilyId).toList();

      final rawAllWarnings = await earlyWarningRepository.getWarnings();
      final allWarnings = rawAllWarnings.where((w) => w.familyId == currentFamilyId).toList();

      final rawAnomalies = await anomalyRepository.getLatestAnomalies();
      final anomalies = rawAnomalies.where((a) => a.familyId == currentFamilyId).toList();

      emit(DailyFinanceLoaded(
        records: filteredRecords,
        incomeRecords: incomeRecords,
        expenseRecords: expenseRecords,
        totalIncomeToday: totalIncomeToday,
        totalExpenseToday: totalExpenseToday,
        dailyBalance: totalIncomeToday - totalExpenseToday,
        totalIncomeThisMonth: totalIncomeThisMonth,
        totalExpenseThisMonth: totalExpenseThisMonth,
        monthlyCashflow: totalIncomeThisMonth - totalExpenseThisMonth,
        filter: _currentFilter,
        latestWarnings: warnings,
        allWarnings: allWarnings,
        anomalies: anomalies,
      ));
    } catch (e) {
      emit(DailyFinanceError('Gagal memuat catatan keuangan: $e'));
    }
  }

  Future<void> addRecord(FinanceRecord record) async {
    try {
      await repository.createRecord(record);
      
      // Trigger anomaly detection if it's an expense
      if (record.type == FinanceRecordType.expense) {
        final anomaly = await anomalyRepository.detectForExpense(record);
        if (anomaly != null && anomaly.increasePercentage > 50) {
          // Create High Anomaly Warning
          await earlyWarningRepository.createWarning(EarlyWarning(
            warningId: const Uuid().v4(),
            familyId: record.familyId,
            userId: record.userId,
            title: 'Pengeluaran Tidak Normal Terdeteksi',
            message: 'Pengeluaran kategori ${record.category} naik ${anomaly.increasePercentage.toStringAsFixed(0)}% dibanding rata-rata historis. Periksa kembali pola belanja periode ini.',
            severity: EarlyWarningSeverity.high,
            source: EarlyWarningSource.anomaly,
            sourceId: anomaly.anomalyId,
            isRead: false,
            createdAt: DateTime.now(),
          ));
        }
      }

      // Check negative cashflow
      final allRecords = await repository.getRecords();
      final now = DateTime.now();
      double totalIncomeThisMonth = 0;
      double totalExpenseThisMonth = 0;

      for (var r in allRecords) {
        if (r.recordDate.year == now.year && r.recordDate.month == now.month) {
          if (r.type == FinanceRecordType.income) totalIncomeThisMonth += r.amount;
          if (r.type == FinanceRecordType.expense) totalExpenseThisMonth += r.amount;
        }
      }
      
      if (totalIncomeThisMonth - totalExpenseThisMonth < 0) {
        await earlyWarningRepository.createWarning(EarlyWarning(
          warningId: const Uuid().v4(),
          familyId: record.familyId,
          userId: record.userId,
          title: 'Cashflow Bulanan Negatif',
          message: 'Pengeluaran bulan ini lebih besar daripada pendapatan yang tercatat. Evaluasi kembali pengeluaran harian.',
          severity: EarlyWarningSeverity.medium,
          source: EarlyWarningSource.dailyFinance,
          sourceId: 'cashflow_${DateTime.now().month}_${DateTime.now().year}',
          isRead: false,
          createdAt: DateTime.now(),
        ));
      }

      emit(const DailyFinanceActionSuccess('Catatan berhasil ditambahkan.'));
      await loadRecords(showLoading: false);
    } catch (e) {
      emit(DailyFinanceError('Gagal menambah catatan: $e'));
      await loadRecords(showLoading: false);
    }
  }

  Future<void> updateRecord(FinanceRecord record) async {
    try {
      await repository.updateRecord(record);
      emit(const DailyFinanceActionSuccess('Catatan berhasil diperbarui.'));
      await loadRecords(showLoading: false);
    } catch (e) {
      emit(DailyFinanceError('Gagal memperbarui catatan: $e'));
      await loadRecords(showLoading: false);
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await repository.deleteRecord(recordId);
      emit(const DailyFinanceActionSuccess('Catatan berhasil dihapus.'));
      await loadRecords(showLoading: false);
    } catch (e) {
      emit(DailyFinanceError('Gagal menghapus catatan: $e'));
      await loadRecords(showLoading: false);
    }
  }

  void applyFilter(String filter) {
    loadRecords(filter: filter);
  }

  Future<void> markWarningAsRead(String warningId) async {
    try {
      await earlyWarningRepository.markAsRead(warningId);
      await loadRecords(showLoading: false); // reload warnings
    } catch (e) {
      emit(DailyFinanceError('Gagal menandai peringatan: $e'));
      await loadRecords(showLoading: false);
    }
  }
}
