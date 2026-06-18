import 'package:equatable/equatable.dart';
import '../../domain/entities/anomaly_result.dart';
import '../../domain/entities/monthly_expense_trend.dart';
import '../../domain/entities/anomaly_combined_record.dart';

abstract class AnomalyState extends Equatable {
  const AnomalyState();

  @override
  List<Object?> get props => [];
}

class AnomalyInitial extends AnomalyState {}

class AnomalyLoading extends AnomalyState {}

class AnomalyLoaded extends AnomalyState {
  final List<AnomalyResult> anomalies;
  final List<MonthlyExpenseTrend> monthlyTrend;
  final List<AnomalyCombinedRecord> recentCombinedRecords;

  const AnomalyLoaded({
    required this.anomalies,
    required this.monthlyTrend,
    required this.recentCombinedRecords,
  });

  @override
  List<Object?> get props => [anomalies, monthlyTrend, recentCombinedRecords];
}

class AnomalyError extends AnomalyState {
  final String message;

  const AnomalyError(this.message);

  @override
  List<Object?> get props => [message];
}
