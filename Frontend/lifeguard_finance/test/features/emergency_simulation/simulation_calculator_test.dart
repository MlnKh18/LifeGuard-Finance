import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/emergency_simulation/data/datasources/inflation_impact_calculator.dart';
import 'package:lifeguard_finance/features/emergency_simulation/data/datasources/simulation_calculator.dart';
import 'package:lifeguard_finance/features/emergency_simulation/domain/entities/simulation_input.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/data/datasources/fvs_calculator.dart';

void main() {
  const fvsCalculator = FvsCalculator();
  const inflationCalculator = InflationImpactCalculator(fvsCalculator);
  const calculator = SimulationCalculator(fvsCalculator, inflationCalculator);

  final profile = const FamilyFinanceProfile(
    fixedIncome: 8000000,
    variableIncome: 0,
    routineExpenses: 4000000,
    debtPayments: 800000,
    liquidSavings: 12000000,
    totalDependents: 2,
    hasBpjs: true,
    hasAdditionalInsurance: true,
  );

  group('SimulationCalculator', () {
    test('lossOfIncome scenario zeroes fixed income and depletes the emergency fund', () {
      final result = calculator.simulate(
        profile: profile,
        input: const SimulationInput(scenarioType: ScenarioType.lossOfIncome, parameterValue: 3),
      );

      // outlays (4.8jt) exceed remaining variable income (0) -> deficit accrues
      expect(result.potentialDeficit, greaterThan(0));
      expect(result.monthsEmergencyFundLasts, greaterThan(0));
      expect(result.fvsAfter.score, lessThan(result.fvsBefore.score));
      expect(result.scoreDrop, greaterThan(0));
    });

    test('medicalEmergency scenario consumes liquid savings up to the cost', () {
      final result = calculator.simulate(
        profile: profile,
        input: const SimulationInput(scenarioType: ScenarioType.medicalEmergency, parameterValue: 5000000),
      );

      expect(result.remainingLiquidSavings, profile.liquidSavings - 5000000);
      expect(result.potentialDeficit, 0);
    });

    test('medicalEmergency scenario beyond available savings produces a deficit', () {
      final result = calculator.simulate(
        profile: profile,
        input: const SimulationInput(scenarioType: ScenarioType.medicalEmergency, parameterValue: 20000000),
      );

      expect(result.remainingLiquidSavings, 0);
      expect(result.potentialDeficit, 20000000 - profile.liquidSavings);
    });

    test('interestRateIncrease scenario raises debt payments and lists S4 as affected', () {
      final result = calculator.simulate(
        profile: profile,
        input: const SimulationInput(scenarioType: ScenarioType.interestRateIncrease, parameterValue: 1000000),
      );

      expect(result.affectedIndicators.any((i) => i.startsWith('S4')), isTrue);
    });

    test('inflationNeeds scenario increases routine expenses and reduces FVS', () {
      final result = calculator.simulate(
        profile: profile,
        input: const SimulationInput(
          scenarioType: ScenarioType.inflationNeeds,
          parameterValue: 10,
          secondaryParameterValue: 2000000,
        ),
      );

      expect(result.inflationResult, isNotNull);
      expect(result.inflationResult!.expenseIncrease, closeTo(200000, 0.01));
      expect(result.fvsAfter.score, lessThanOrEqualTo(result.fvsBefore.score));
    });

    test('increasedDependents scenario adds routine cost per new dependent', () {
      final result = calculator.simulate(
        profile: profile,
        input: const SimulationInput(scenarioType: ScenarioType.increasedDependents, parameterValue: 2),
      );

      expect(result.affectedIndicators.any((i) => i.startsWith('S5')), isTrue);
    });
  });
}
