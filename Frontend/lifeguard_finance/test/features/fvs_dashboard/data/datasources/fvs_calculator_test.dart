import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';

void main() {
  late FvsCalculator calculator;

  setUp(() {
    calculator = const FvsCalculator();
  });

  group('FvsCalculator Unit Tests', () {
    test('Should return high score (Aman) for healthy finance profile', () {
      final profile = FamilyFinanceProfile(
        fixedIncome: 20000000,
        variableIncome: 2000000,
        routineExpenses: 5000000,
        debtPayments: 1000000,
        liquidSavings: 50000000,
        totalDependents: 2,
        hasBpjs: true,
        hasAdditionalInsurance: true,
      );

      final result = calculator.calculate(profile);

      expect(result.score, greaterThanOrEqualTo(80));
      expect(result.category, 'Aman');
      expect(result.s3, 100.0); // Emergency fund covers > 6 months
      expect(result.s6, 100.0); // Has both BPJS and Insurance
    });

    test('Should return low score (Kritis) for zero income with debt', () {
      final profile = FamilyFinanceProfile(
        fixedIncome: 0,
        variableIncome: 0,
        routineExpenses: 3000000,
        debtPayments: 2000000,
        liquidSavings: 1000000,
        totalDependents: 4,
        hasBpjs: false,
        hasAdditionalInsurance: false,
      );

      final result = calculator.calculate(profile);

      expect(result.score, lessThan(40));
      expect(result.category, 'Kritis');
      expect(result.s4, 10.0); // High debt burden relative to 0 income
    });
  });
}
