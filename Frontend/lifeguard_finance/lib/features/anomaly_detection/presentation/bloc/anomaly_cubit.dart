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

  Future<void> addTransaction({
    required String category,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final current = state;
    if (current is! AnomalyLoaded) return;

    final newTransaction = ExpenseTransaction(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      date: date,
      note: note,
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
    final categoryResults = anomalyDetectionService.analyzeCategories(transactions);
    final flagged = anomalyDetectionService.flagTransactions(transactions, categoryResults);
    final monthlyTrend = anomalyDetectionService.computeMonthlyTrend(transactions);
    emit(AnomalyLoaded(transactions: flagged, monthlyTrend: monthlyTrend, categoryResults: categoryResults));
  }

  Future<void> _persist(List<ExpenseTransaction> transactions) async {
    await hiveService.saveData(LocalKeys.expenseHistory, transactions.map((t) => t.toJson()).toList());
  }

  List<ExpenseTransaction> _seedTransactions() {
    final now = DateTime.now();
    DateTime monthsAgo(int months, int day) => DateTime(now.year, now.month - months, day);
    String id() => const Uuid().v4();

    return [
      // Makanan: steady ~1.2jt/bulan, lalu melonjak ke 1.9jt bulan ini (+58% -> Anomali Tinggi)
      ExpenseTransaction(id: id(), category: 'Makanan', amount: 1180000, date: monthsAgo(4, 5)),
      ExpenseTransaction(id: id(), category: 'Makanan', amount: 1220000, date: monthsAgo(3, 6)),
      ExpenseTransaction(id: id(), category: 'Makanan', amount: 1150000, date: monthsAgo(2, 4)),
      ExpenseTransaction(id: id(), category: 'Makanan', amount: 1250000, date: monthsAgo(1, 5)),
      ExpenseTransaction(id: id(), category: 'Makanan', amount: 1900000, date: monthsAgo(0, 6)),

      // Transportasi: steady ~600rb/bulan, bulan ini 650rb (+8% -> Normal)
      ExpenseTransaction(id: id(), category: 'Transportasi', amount: 610000, date: monthsAgo(4, 12)),
      ExpenseTransaction(id: id(), category: 'Transportasi', amount: 590000, date: monthsAgo(3, 11)),
      ExpenseTransaction(id: id(), category: 'Transportasi', amount: 605000, date: monthsAgo(2, 13)),
      ExpenseTransaction(id: id(), category: 'Transportasi', amount: 595000, date: monthsAgo(1, 12)),
      ExpenseTransaction(id: id(), category: 'Transportasi', amount: 650000, date: monthsAgo(0, 12)),

      // Cicilan: tetap setiap bulan (0% -> Normal)
      ExpenseTransaction(id: id(), category: 'Cicilan', amount: 1200000, date: monthsAgo(3, 1)),
      ExpenseTransaction(id: id(), category: 'Cicilan', amount: 1200000, date: monthsAgo(2, 1)),
      ExpenseTransaction(id: id(), category: 'Cicilan', amount: 1200000, date: monthsAgo(1, 1)),
      ExpenseTransaction(id: id(), category: 'Cicilan', amount: 1200000, date: monthsAgo(0, 1)),

      // Hiburan: steady ~400rb/bulan, bulan ini 540rb (+35% -> Anomali Ringan)
      ExpenseTransaction(id: id(), category: 'Hiburan', amount: 380000, date: monthsAgo(3, 18)),
      ExpenseTransaction(id: id(), category: 'Hiburan', amount: 420000, date: monthsAgo(2, 20)),
      ExpenseTransaction(id: id(), category: 'Hiburan', amount: 400000, date: monthsAgo(1, 19)),
      ExpenseTransaction(id: id(), category: 'Hiburan', amount: 540000, date: monthsAgo(0, 20), note: 'Nonton + makan di luar'),

      // Belanja Rumah Tangga: steady ~900rb/bulan, bulan ini 950rb (+5.5% -> Normal)
      ExpenseTransaction(id: id(), category: 'Belanja Rumah Tangga', amount: 880000, date: monthsAgo(2, 24)),
      ExpenseTransaction(id: id(), category: 'Belanja Rumah Tangga', amount: 910000, date: monthsAgo(1, 23)),
      ExpenseTransaction(id: id(), category: 'Belanja Rumah Tangga', amount: 950000, date: monthsAgo(0, 24)),

      // Kesehatan: hanya muncul bulan ini, tanpa riwayat -> dianggap baseline (Normal)
      ExpenseTransaction(id: id(), category: 'Kesehatan', amount: 250000, date: monthsAgo(0, 15)),
    ];
  }
}
