import 'package:equatable/equatable.dart';
import '../../domain/entities/finance_record_entity.dart';
import '../../../anomaly_detection/domain/entities/anomaly_result.dart';
import '../../../early_warning/domain/entities/early_warning.dart';

abstract class DailyFinanceState extends Equatable {
  const DailyFinanceState();

  @override
  List<Object?> get props => [];
}

class DailyFinanceInitial extends DailyFinanceState {}

class DailyFinanceLoading extends DailyFinanceState {}

class DailyFinanceLoaded extends DailyFinanceState {
  final List<FinanceRecord> records;
  final List<FinanceRecord> incomeRecords;
  final List<FinanceRecord> expenseRecords;
  final double totalIncomeToday;
  final double totalExpenseToday;
  final double dailyBalance;
  final double totalIncomeThisMonth;
  final double totalExpenseThisMonth;
  final double monthlyCashflow;
  final String filter; // 'Semua', 'Pendapatan', 'Pengeluaran', 'Hari ini', 'Minggu ini', 'Bulan ini'
  final List<EarlyWarning> latestWarnings; // unread warnings
  final List<EarlyWarning> allWarnings;
  final List<AnomalyResult> anomalies;

  const DailyFinanceLoaded({
    required this.records,
    required this.incomeRecords,
    required this.expenseRecords,
    required this.totalIncomeToday,
    required this.totalExpenseToday,
    required this.dailyBalance,
    required this.totalIncomeThisMonth,
    required this.totalExpenseThisMonth,
    required this.monthlyCashflow,
    this.filter = 'Semua',
    this.latestWarnings = const [],
    this.allWarnings = const [],
    this.anomalies = const [],
  });

  @override
  List<Object?> get props => [
        records,
        incomeRecords,
        expenseRecords,
        totalIncomeToday,
        totalExpenseToday,
        dailyBalance,
        totalIncomeThisMonth,
        totalExpenseThisMonth,
        monthlyCashflow,
        filter,
        latestWarnings,
        allWarnings,
        anomalies,
      ];
}

class DailyFinanceActionSuccess extends DailyFinanceState {
  final String message;

  const DailyFinanceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DailyFinanceError extends DailyFinanceState {
  final String message;

  const DailyFinanceError(this.message);

  @override
  List<Object?> get props => [message];
}
