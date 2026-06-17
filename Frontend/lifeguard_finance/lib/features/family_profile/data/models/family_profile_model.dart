import '../../domain/entities/family_profile_entity.dart';

class FamilyFinanceProfileModel extends FamilyFinanceProfile {
  const FamilyFinanceProfileModel({
    required super.fixedIncome,
    required super.variableIncome,
    required super.routineExpenses,
    required super.debtPayments,
    required super.liquidSavings,
    required super.totalDependents,
    required super.hasBpjs,
    required super.hasAdditionalInsurance,
  });

  factory FamilyFinanceProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyFinanceProfileModel(
      fixedIncome: (json['fixedIncome'] as num).toDouble(),
      variableIncome: (json['variableIncome'] as num).toDouble(),
      routineExpenses: (json['routineExpenses'] as num).toDouble(),
      debtPayments: (json['debtPayments'] as num).toDouble(),
      liquidSavings: (json['liquidSavings'] as num).toDouble(),
      totalDependents: json['totalDependents'] as int,
      hasBpjs: json['hasBpjs'] as bool,
      hasAdditionalInsurance: json['hasAdditionalInsurance'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fixedIncome': fixedIncome,
      'variableIncome': variableIncome,
      'routineExpenses': routineExpenses,
      'debtPayments': debtPayments,
      'liquidSavings': liquidSavings,
      'totalDependents': totalDependents,
      'hasBpjs': hasBpjs,
      'hasAdditionalInsurance': hasAdditionalInsurance,
    };
  }

  factory FamilyFinanceProfileModel.fromEntity(FamilyFinanceProfile entity) {
    return FamilyFinanceProfileModel(
      fixedIncome: entity.fixedIncome,
      variableIncome: entity.variableIncome,
      routineExpenses: entity.routineExpenses,
      debtPayments: entity.debtPayments,
      liquidSavings: entity.liquidSavings,
      totalDependents: entity.totalDependents,
      hasBpjs: entity.hasBpjs,
      hasAdditionalInsurance: entity.hasAdditionalInsurance,
    );
  }
}
