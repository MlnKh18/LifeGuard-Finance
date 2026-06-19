import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_finance/features/smart_routing/data/datasources/smart_routing_calculator.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';

void main() {
  late SmartRoutingCalculator calculator;

  setUp(() {
    calculator = const SmartRoutingCalculator();
  });

  group('SmartRoutingCalculator Tests', () {
    test('Calculate Routing for Aman Category', () {
      final profile = FamilyFinanceProfile(
        fixedIncome: 10000000,
        variableIncome: 0,
        routineExpenses: 5000000,
        debtPayments: 2000000,
        liquidSavings: 10000000,
        totalDependents: 2,
        hasBpjs: true,
        hasAdditionalInsurance: false,
      );

      final result = calculator.calculate(profile: profile, fvsCategory: 'Aman');

      // Total income = 10,000,000
      expect(result.totalIncome, 10000000.0);
      expect(result.fvsCategory, 'Aman');
      
      final kebutuhanPokok = result.allocations.firstWhere((a) => a.category == 'Kebutuhan Pokok');
      final cicilan = result.allocations.firstWhere((a) => a.category == 'Cicilan');
      
      expect(kebutuhanPokok.percentage, 45);
      expect(kebutuhanPokok.amount, 4500000.0);
      
      expect(cicilan.percentage, 20);
      expect(cicilan.amount, 2000000.0);
    });

    test('Calculate Routing for Kritis Category', () {
      final profile = FamilyFinanceProfile(
        fixedIncome: 5000000,
        variableIncome: 0,
        routineExpenses: 6000000,
        debtPayments: 1000000,
        liquidSavings: 0,
        totalDependents: 1,
        hasBpjs: false,
        hasAdditionalInsurance: false,
      );

      final result = calculator.calculate(profile: profile, fvsCategory: 'Kritis');

      expect(result.totalIncome, 5000000.0);
      expect(result.fvsCategory, 'Kritis');
      
      final kebutuhanPokok = result.allocations.firstWhere((a) => a.category == 'Kebutuhan Pokok');
      final tabungan = result.allocations.firstWhere((a) => a.category == 'Tabungan Keluarga');
      
      expect(kebutuhanPokok.percentage, 60);
      expect(kebutuhanPokok.amount, 3000000.0);
      
      expect(tabungan.percentage, 0);
      expect(tabungan.amount, 0.0);
    });
  });
}
