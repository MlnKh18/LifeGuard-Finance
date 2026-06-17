import 'package:equatable/equatable.dart';

class InflationImpactResult extends Equatable {
  final double routineExpensesAfter;
  final double expenseIncrease;
  final double monthsEmergencyFundLastsBefore;
  final double monthsEmergencyFundLastsAfter;
  final double fvsScoreBefore;
  final double fvsScoreAfter;
  final double fvsScoreChange;
  final String warningMessage;

  const InflationImpactResult({
    required this.routineExpensesAfter,
    required this.expenseIncrease,
    required this.monthsEmergencyFundLastsBefore,
    required this.monthsEmergencyFundLastsAfter,
    required this.fvsScoreBefore,
    required this.fvsScoreAfter,
    required this.fvsScoreChange,
    required this.warningMessage,
  });

  factory InflationImpactResult.fromJson(Map<String, dynamic> json) {
    return InflationImpactResult(
      routineExpensesAfter: (json['routineExpensesAfter'] as num).toDouble(),
      expenseIncrease: (json['expenseIncrease'] as num).toDouble(),
      monthsEmergencyFundLastsBefore: (json['monthsEmergencyFundLastsBefore'] as num).toDouble(),
      monthsEmergencyFundLastsAfter: (json['monthsEmergencyFundLastsAfter'] as num).toDouble(),
      fvsScoreBefore: (json['fvsScoreBefore'] as num).toDouble(),
      fvsScoreAfter: (json['fvsScoreAfter'] as num).toDouble(),
      fvsScoreChange: (json['fvsScoreChange'] as num).toDouble(),
      warningMessage: json['warningMessage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routineExpensesAfter': routineExpensesAfter,
      'expenseIncrease': expenseIncrease,
      'monthsEmergencyFundLastsBefore': monthsEmergencyFundLastsBefore,
      'monthsEmergencyFundLastsAfter': monthsEmergencyFundLastsAfter,
      'fvsScoreBefore': fvsScoreBefore,
      'fvsScoreAfter': fvsScoreAfter,
      'fvsScoreChange': fvsScoreChange,
      'warningMessage': warningMessage,
    };
  }

  @override
  List<Object?> get props => [
        routineExpensesAfter,
        expenseIncrease,
        monthsEmergencyFundLastsBefore,
        monthsEmergencyFundLastsAfter,
        fvsScoreBefore,
        fvsScoreAfter,
        fvsScoreChange,
        warningMessage,
      ];
}
