import 'package:equatable/equatable.dart';
import 'expense_transaction.dart';

class AnomalyResult extends Equatable {
  final String category;
  final double historicalAverage;
  final double currentAmount;
  final double percentageIncrease;
  final AnomalySeverity severity;
  final double estimatedFvsImpact; // negative = FVS points likely to drop
  final String warningMessage;

  const AnomalyResult({
    required this.category,
    required this.historicalAverage,
    required this.currentAmount,
    required this.percentageIncrease,
    required this.severity,
    required this.estimatedFvsImpact,
    required this.warningMessage,
  });

  @override
  List<Object?> get props => [
        category,
        historicalAverage,
        currentAmount,
        percentageIncrease,
        severity,
        estimatedFvsImpact,
        warningMessage,
      ];
}
