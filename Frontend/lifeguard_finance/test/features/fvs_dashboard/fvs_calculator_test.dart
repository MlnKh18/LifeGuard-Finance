import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/data/datasources/fvs_calculator.dart';

void main() {
  const calculator = FvsCalculator();

  FamilyFinanceProfile profileOf({
    double fixedIncome = 8000000,
    double variableIncome = 0,
    double routineExpenses = 4000000,
    double debtPayments = 800000,
    double liquidSavings = 24000000,
    int totalDependents = 2,
    bool hasBpjs = true,
    bool hasAdditionalInsurance = true,
  }) {
    return FamilyFinanceProfile(
      fixedIncome: fixedIncome,
      variableIncome: variableIncome,
      routineExpenses: routineExpenses,
      debtPayments: debtPayments,
      liquidSavings: liquidSavings,
      totalDependents: totalDependents,
      hasBpjs: hasBpjs,
      hasAdditionalInsurance: hasAdditionalInsurance,
    );
  }

  group('FvsCalculator', () {
    test('classifies a healthy profile as Aman (score >= 80)', () {
      final result = calculator.calculate(profileOf());

      expect(result.category, 'Aman');
      expect(result.score, greaterThanOrEqualTo(80));
    });

    test('classifies a profile with no savings, high debt, and unstable income as Kritis', () {
      final result = calculator.calculate(profileOf(
        fixedIncome: 0,
        variableIncome: 8000000,
        routineExpenses: 8000000,
        debtPayments: 6000000,
        liquidSavings: 0,
        totalDependents: 6,
        hasBpjs: false,
        hasAdditionalInsurance: false,
      ));

      expect(result.category, 'Kritis');
      expect(result.score, lessThan(40));
    });

    test('applies the exact spec weighting formula', () {
      final profile = profileOf();
      final result = calculator.calculate(profile);

      final expected = (0.20 * result.s1) +
          (0.15 * result.s2) +
          (0.20 * result.s3) +
          (0.20 * result.s4) +
          (0.10 * result.s5) +
          (0.10 * result.s6) +
          (0.05 * result.s7);

      expect(result.score, closeTo(expected, 0.0001));
    });

    test('does not divide by zero when total income is zero', () {
      final result = calculator.calculate(profileOf(fixedIncome: 0, variableIncome: 0));

      expect(result.score, isNotNull);
      expect(result.score.isNaN, isFalse);
    });

    test('S3 emergency fund score reaches maximum at 6+ months of coverage', () {
      final result = calculator.calculate(profileOf(routineExpenses: 1000000, liquidSavings: 6000000));

      expect(result.s3, 100.0);
    });
  });
}
