import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/emergency_simulation/data/datasources/simulation_calculator.dart';
import 'package:lifeguard_finance/features/emergency_simulation/domain/entities/simulation_input.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import 'package:lifeguard_finance/features/emergency_simulation/data/datasources/inflation_impact_calculator.dart';

void main() {
  late SimulationCalculator calculator;

  setUp(() {
    final fvsCalc = const FvsCalculator();
    calculator = SimulationCalculator(fvsCalc, InflationImpactCalculator(fvsCalc));
  });

  group('SimulationCalculator Tests', () {
    test('Simulate PHK (Loss of Income)', () {
      final profile = FamilyFinanceProfile(
        fixedIncome: 10000000,
        variableIncome: 0,
        routineExpenses: 5000000,
        debtPayments: 2000000,
        liquidSavings: 30000000, // 6 months of expenses
        totalDependents: 2,
        hasBpjs: true,
        hasAdditionalInsurance: false,
      );

      final input = SimulationInput(
        scenarioType: ScenarioType.lossOfIncome,
        parameterValue: 6, // 6 months
      );

      final result = calculator.simulate(profile: profile, input: input);

      expect(result.potentialDeficit, 42000000.0); // (5M + 2M) * 6
      expect(result.fvsBefore.score, greaterThan(result.fvsAfter.score));
      expect(result.monthsEmergencyFundLasts, lessThan(6.0));
      expect(result.scoreDrop, greaterThan(0));
    });

    test('Simulate Medical Emergency', () {
      final profile = FamilyFinanceProfile(
        fixedIncome: 10000000,
        variableIncome: 0,
        routineExpenses: 5000000,
        debtPayments: 0,
        liquidSavings: 20000000,
        totalDependents: 1,
        hasBpjs: false,
        hasAdditionalInsurance: false,
      );

      final input = SimulationInput(
        scenarioType: ScenarioType.medicalEmergency,
        parameterValue: 30000000, // 30M cost
      );

      final result = calculator.simulate(profile: profile, input: input);

      expect(result.remainingLiquidSavings, 0.0); // Savings wiped out
      expect(result.potentialDeficit, 10000000.0); // 10M deficit
      expect(result.monthsEmergencyFundLasts, 0.0);
    });
  });
}
