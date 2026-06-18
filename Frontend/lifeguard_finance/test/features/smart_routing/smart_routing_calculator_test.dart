import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/smart_routing/data/datasources/smart_routing_calculator.dart';

void main() {
  const calculator = SmartRoutingCalculator();

  final profile = const FamilyFinanceProfile(
    fixedIncome: 8000000,
    variableIncome: 2000000,
    routineExpenses: 4000000,
    debtPayments: 800000,
    liquidSavings: 12000000,
    totalDependents: 2,
    hasBpjs: true,
    hasAdditionalInsurance: true,
  );

  group('SmartRoutingCalculator', () {
    for (final category in ['Aman', 'Waspada', 'Rentan', 'Kritis']) {
      test('allocation percentages for $category sum to 100%', () {
        final plan = calculator.calculate(profile: profile, fvsCategory: category);
        final totalPercentage = plan.allocations.fold<double>(0, (sum, a) => sum + a.percentage);

        expect(totalPercentage, closeTo(100, 0.001));
      });

      test('allocation amounts for $category sum to total income', () {
        final plan = calculator.calculate(profile: profile, fvsCategory: category);
        final totalAmount = plan.allocations.fold<double>(0, (sum, a) => sum + a.amount);

        expect(totalAmount, closeTo(plan.totalIncome, 0.001));
      });
    }

    test('totalIncome equals fixed + variable income', () {
      final plan = calculator.calculate(profile: profile, fvsCategory: 'Aman');

      expect(plan.totalIncome, profile.fixedIncome + profile.variableIncome);
    });

    test('unknown category falls back to the Kritis allocation table', () {
      final plan = calculator.calculate(profile: profile, fvsCategory: 'TidakDikenal');
      final kritisPlan = calculator.calculate(profile: profile, fvsCategory: 'Kritis');

      expect(plan.allocations, kritisPlan.allocations);
    });

    test('Kritis category leaves no allocation for family savings', () {
      final plan = calculator.calculate(profile: profile, fvsCategory: 'Kritis');
      final savings = plan.allocations.firstWhere((a) => a.category == 'Tabungan Keluarga');

      expect(savings.percentage, 0);
    });
  });
}
