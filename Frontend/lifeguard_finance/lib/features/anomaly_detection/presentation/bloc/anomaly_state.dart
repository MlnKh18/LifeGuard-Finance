import 'package:equatable/equatable.dart';
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

  const AnomalyLoaded({required this.transactions, required this.monthlyTrend});

  int get anomalyCount => transactions.where((t) => t.isAnomaly).length + monthlyTrend.where((m) => m.isAnomaly).length;

  @override
  List<Object?> get props => [transactions, monthlyTrend];
}

class AnomalyError extends AnomalyState {
  final String message;

  const AnomalyError(this.message);

  @override
  List<Object?> get props => [message];
}
