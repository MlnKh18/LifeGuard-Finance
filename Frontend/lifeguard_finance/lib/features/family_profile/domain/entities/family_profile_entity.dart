import 'package:equatable/equatable.dart';

class FamilyFinanceProfile extends Equatable {
  final double fixedIncome;
  final double variableIncome;
  final double routineExpenses;
  final double debtPayments;
  final double liquidSavings;
  final int totalDependents;
  final bool hasBpjs;
  final bool hasAdditionalInsurance;

  const FamilyFinanceProfile({
    required this.fixedIncome,
    required this.variableIncome,
    required this.routineExpenses,
    required this.debtPayments,
    required this.liquidSavings,
    required this.totalDependents,
    required this.hasBpjs,
    required this.hasAdditionalInsurance,
  });

  @override
  List<Object?> get props => [
        fixedIncome,
        variableIncome,
        routineExpenses,
        debtPayments,
        liquidSavings,
        totalDependents,
        hasBpjs,
        hasAdditionalInsurance,
      ];
}
