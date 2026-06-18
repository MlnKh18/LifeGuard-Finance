import 'package:equatable/equatable.dart';
import '../../domain/entities/anomaly_result.dart';
import '../../domain/entities/expense_transaction.dart';
import '../../domain/entities/monthly_expense_trend.dart';

abstract class AnomalyState extends Equatable {
  const AnomalyState();

  @override
  List<Object?> get props => [];
}

class AnomalyLoading extends AnomalyState {}

class AnomalyLoaded extends AnomalyState {
  final List<ExpenseTransaction> transactions;
  final List<MonthlyExpenseTrend> monthlyTrend;
  final List<AnomalyResult> categoryResults;

  const AnomalyLoaded({
    required this.transactions,
    required this.monthlyTrend,
    required this.categoryResults,
  });

  List<AnomalyResult> get spikingCategories => categoryResults.where((r) => r.severity != AnomalySeverity.normal).toList();

  int get anomalyCount => spikingCategories.length;

  @override
  List<Object?> get props => [transactions, monthlyTrend, categoryResults];
}

class AnomalyError extends AnomalyState {
  final String message;

  const AnomalyError(this.message);

  @override
  List<Object?> get props => [message];
}
