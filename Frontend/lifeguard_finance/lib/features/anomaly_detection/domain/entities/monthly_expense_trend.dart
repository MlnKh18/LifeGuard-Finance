import 'package:equatable/equatable.dart';

class MonthlyExpenseTrend extends Equatable {
  final DateTime month;
  final double totalAmount;
  final bool isAnomaly;
  final double zScore;

  const MonthlyExpenseTrend({
    required this.month,
    required this.totalAmount,
    required this.isAnomaly,
    required this.zScore,
  });

  @override
  List<Object?> get props => [month, totalAmount, isAnomaly, zScore];
}
