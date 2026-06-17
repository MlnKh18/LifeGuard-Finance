import '../../domain/entities/inflation_impact_result.dart';
import '../../../fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';

class InflationImpactCalculator {
  final FvsCalculator fvsCalculator;

  const InflationImpactCalculator(this.fvsCalculator);

  InflationImpactResult calculate({
    required FamilyFinanceProfile profile,
    required double primaryNeedsExpense,
    required double inflationRate,
  }) {
    final double routineExpenses = profile.routineExpenses;
    final double expenseIncrease = primaryNeedsExpense * (inflationRate / 100);
    final double routineExpensesAfter = routineExpenses + expenseIncrease;

    final double liquidSavings = profile.liquidSavings;
    final double monthsEmergencyFundLastsBefore =
        routineExpenses > 0 ? liquidSavings / routineExpenses : 99.0;
    final double monthsEmergencyFundLastsAfter =
        routineExpensesAfter > 0 ? liquidSavings / routineExpensesAfter : 99.0;

    final fvsScoreBefore = fvsCalculator.calculate(profile);

    final simulatedProfile = FamilyFinanceProfile(
      fixedIncome: profile.fixedIncome,
      variableIncome: profile.variableIncome,
      routineExpenses: routineExpensesAfter,
      debtPayments: profile.debtPayments,
      liquidSavings: profile.liquidSavings,
      totalDependents: profile.totalDependents,
      hasBpjs: profile.hasBpjs,
      hasAdditionalInsurance: profile.hasAdditionalInsurance,
    );

    final fvsScoreAfter = fvsCalculator.calculate(simulatedProfile);
    final double fvsScoreChange = fvsScoreAfter.score - fvsScoreBefore.score;

    String warningMessage = '';
    if (monthsEmergencyFundLastsAfter < 3.0) {
      warningMessage =
          '⚠️ Kritis: Laju inflasi ini menurunkan daya tahan dana darurat Anda menjadi ${monthsEmergencyFundLastsAfter.toStringAsFixed(1)} bulan (di bawah batas minimal aman 3 bulan). Hubungi penasihat keuangan atau segera pangkas pengeluaran sekunder Anda!';
    } else if (monthsEmergencyFundLastsAfter < 6.0) {
      warningMessage =
          '⚠️ Waspada: Masa ketahanan dana darurat Anda berkurang menjadi ${monthsEmergencyFundLastsAfter.toStringAsFixed(1)} bulan. Disarankan untuk menambah alokasi dana darurat hingga mencapai ketahanan 6 bulan.';
    } else {
      warningMessage =
          '✅ Aman: Dana darurat Anda diproyeksikan mampu bertahan selama ${monthsEmergencyFundLastsAfter.toStringAsFixed(1)} bulan pasca inflasi.';
    }

    return InflationImpactResult(
      routineExpensesAfter: routineExpensesAfter,
      expenseIncrease: expenseIncrease,
      monthsEmergencyFundLastsBefore: monthsEmergencyFundLastsBefore,
      monthsEmergencyFundLastsAfter: monthsEmergencyFundLastsAfter,
      fvsScoreBefore: fvsScoreBefore.score,
      fvsScoreAfter: fvsScoreAfter.score,
      fvsScoreChange: fvsScoreChange,
      warningMessage: warningMessage,
    );
  }
}
