import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../data/datasources/anomaly_detection_service.dart';
import '../../domain/entities/expense_transaction.dart';
import 'anomaly_state.dart';

class AnomalyCubit extends Cubit<AnomalyState> {
  final HiveService hiveService;
  final AnomalyDetectionService anomalyDetectionService;

  AnomalyCubit({required this.hiveService, required this.anomalyDetectionService}) : super(AnomalyLoading());

  Future<void> loadTransactions() async {
    emit(AnomalyLoading());
    try {
      final raw = hiveService.getData(LocalKeys.expenseHistory);
      List<ExpenseTransaction> transactions;
      if (raw != null) {
        transactions = (raw as List)
            .map((e) => ExpenseTransaction.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        transactions = _seedTransactions();
        await _persist(transactions);
      }
      _emitAnalyzed(transactions);
    } catch (e) {
      emit(AnomalyError('Gagal memuat riwayat pengeluaran: $e'));
    }
  }

  Future<void> addTransaction({required String category, required double amount, required DateTime date}) async {
    final current = state;
    if (current is! AnomalyLoaded) return;

    final newTransaction = ExpenseTransaction(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      date: date,
    );
    final updated = [...current.transactions, newTransaction];
    await _persist(updated);
    _emitAnalyzed(updated);
  }

  Future<void> setReviewStatus(String transactionId, TransactionReviewStatus status) async {
    final current = state;
    if (current is! AnomalyLoaded) return;

    final updated = current.transactions
        .map((t) => t.id == transactionId ? t.copyWith(reviewStatus: status) : t)
        .toList();
    await _persist(updated);
    _emitAnalyzed(updated);
  }

  void _emitAnalyzed(List<ExpenseTransaction> transactions) {
    final flagged = anomalyDetectionService.flagAnomalies(transactions);
    final monthlyTrend = anomalyDetectionService.computeMonthlyTrend(transactions);
    emit(AnomalyLoaded(transactions: flagged, monthlyTrend: monthlyTrend));
  }

  Future<void> _persist(List<ExpenseTransaction> transactions) async {
    await hiveService.saveData(LocalKeys.expenseHistory, transactions.map((t) => t.toJson()).toList());
  }

  List<ExpenseTransaction> _seedTransactions() {
    final now = DateTime.now();
    DateTime monthsAgo(int months, int day) => DateTime(now.year, now.month - months, day);

    return [
      ExpenseTransaction(id: const Uuid().v4(), category: 'Belanja Bulanan', amount: 1850000, date: monthsAgo(5, 24)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Transportasi', amount: 620000, date: monthsAgo(5, 12)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Belanja Bulanan', amount: 1920000, date: monthsAgo(4, 22)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Hiburan & Makan', date: monthsAgo(4, 10), amount: 850000),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Belanja Bulanan', amount: 1780000, date: monthsAgo(3, 23)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Transportasi', amount: 580000, date: monthsAgo(3, 11)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Belanja Bulanan', amount: 2100000, date: monthsAgo(2, 24)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Hiburan & Makan', amount: 900000, date: monthsAgo(2, 9)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Belanja Bulanan', amount: 1950000, date: monthsAgo(1, 24)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Elektronik', amount: 12450000, date: monthsAgo(1, 15)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Transportasi', amount: 610000, date: monthsAgo(1, 12)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Hiburan & Makan', amount: 870000, date: monthsAgo(1, 10)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Belanja Bulanan', amount: 1880000, date: monthsAgo(0, 24)),
      ExpenseTransaction(id: const Uuid().v4(), category: 'Transportasi', amount: 595000, date: monthsAgo(0, 12)),
    ];
  }
}
