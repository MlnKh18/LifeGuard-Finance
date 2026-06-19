import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../daily_finance/domain/entities/finance_record_entity.dart';
import '../../../daily_finance/domain/repositories/finance_record_repository.dart';
import '../../data/datasources/anomaly_detection_service.dart';
import '../../domain/entities/expense_transaction.dart';
import '../../domain/repositories/anomaly_repository.dart';
import 'anomaly_state.dart';

class AnomalyCubit extends Cubit<AnomalyState> {
  final HiveService hiveService;
  final AnomalyDetectionService anomalyDetectionService;
  final FinanceRecordRepository financeRecordRepository;
  final AnomalyRepository anomalyRepository;
  final AuthRepository authRepository;
  StreamSubscription? _recordsSubscription;

  AnomalyCubit({
    required this.hiveService,
    required this.anomalyDetectionService,
    required this.financeRecordRepository,
    required this.anomalyRepository,
    required this.authRepository,
  }) : super(AnomalyLoading()) {
    _recordsSubscription = hiveService.watchKey(LocalKeys.financeRecords).listen((_) {
      loadTransactions();
    });
  }

  @override
  Future<void> close() {
    _recordsSubscription?.cancel();
    return super.close();
  }

  Future<void> loadTransactions() async {
    emit(AnomalyLoading());
    try {
      // 1. Trigger check and seed dummy data if it doesn't exist
      await anomalyRepository.getLatestAnomalies();

      // 2. Fetch all finance records for the current family
      final session = await authRepository.getCurrentSession();
      final currentUser = await authRepository.getCurrentUser();
      final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';

      final allRecords = await financeRecordRepository.getRecords();
      final familyExpenses = allRecords
          .where((r) => r.familyId == currentFamilyId && r.type == FinanceRecordType.expense)
          .toList();

      // 3. Map to ExpenseTransaction objects, using a persistent review status map
      final reviewStatuses = hiveService.getData('anomaly_review_statuses') as Map? ?? {};

      final transactions = familyExpenses.map((r) {
        final statusName = reviewStatuses[r.recordId] as String?;
        final reviewStatus = TransactionReviewStatus.values.firstWhere(
          (s) => s.name == statusName,
          orElse: () => TransactionReviewStatus.pending,
        );
        return ExpenseTransaction(
          id: r.recordId,
          category: getCategoryLabel(r.category),
          amount: r.amount,
          date: r.recordDate,
          note: r.notes,
          reviewStatus: reviewStatus,
        );
      }).toList();

      _emitAnalyzed(transactions);
    } catch (e) {
      emit(AnomalyError('Gagal memuat riwayat pengeluaran: $e'));
    }
  }

  Future<void> addTransaction({
    required String category,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();
    final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';
    final currentUserId = currentUser?.userId ?? '';
    final currentEmail = currentUser?.email ?? '';

    final record = FinanceRecord(
      recordId: const Uuid().v4(),
      familyId: currentFamilyId,
      userId: currentUserId,
      userEmail: currentEmail,
      type: FinanceRecordType.expense,
      category: category,
      amount: amount,
      recordDate: date,
      notes: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await financeRecordRepository.createRecord(record);
    await loadTransactions();
  }

  Future<void> setReviewStatus(String transactionId, TransactionReviewStatus status) async {
    final reviewStatuses = Map<String, String>.from(hiveService.getData('anomaly_review_statuses') as Map? ?? {});
    reviewStatuses[transactionId] = status.name;
    await hiveService.saveData('anomaly_review_statuses', reviewStatuses);
    await loadTransactions();
  }

  void _emitAnalyzed(List<ExpenseTransaction> transactions) {
    final categoryResults = anomalyDetectionService.analyzeCategories(transactions);
    final flagged = anomalyDetectionService.flagTransactions(transactions, categoryResults);
    final monthlyTrend = anomalyDetectionService.computeMonthlyTrend(transactions);
    emit(AnomalyLoaded(transactions: flagged, monthlyTrend: monthlyTrend, categoryResults: categoryResults));
  }
}
