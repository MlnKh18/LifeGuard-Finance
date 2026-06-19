import '../../domain/entities/fvs_score_entity.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';

class FvsCalculator {
  const FvsCalculator();

  FvsScore calculate(FamilyFinanceProfile profile) {
    final totalIncome = profile.fixedIncome + profile.variableIncome;

    // S1: Income Stability Score (fixed vs variable ratio)
    double s1 = 0.0;
    if (totalIncome > 0) {
      s1 = (profile.fixedIncome / totalIncome) * 100;
    }

    // S2: Expense Ratio Score (spending ratio)
    double s2 = 10.0;
    if (totalIncome > 0) {
      final expenseRatio = profile.routineExpenses / totalIncome;
      if (expenseRatio <= 0.3) {
        s2 = 100.0;
      } else if (expenseRatio <= 0.5) {
        s2 = 80.0;
      } else if (expenseRatio <= 0.7) {
        s2 = 50.0;
      } else if (expenseRatio <= 0.9) {
        s2 = 30.0;
      }
    }

    // S3: Emergency Fund Coverage Score (months of expense coverage)
    double s3 = 20.0;
    if (profile.routineExpenses > 0) {
      final monthsCovered = profile.liquidSavings / profile.routineExpenses;
      if (monthsCovered >= 6) {
        s3 = 100.0;
      } else if (monthsCovered >= 3) {
        s3 = 80.0;
      } else if (monthsCovered >= 1) {
        s3 = 50.0;
      }
    } else {
      s3 = 100.0;
    }

    // S4: Debt Burden Ratio Score (debt payments ratio)
    double s4 = 100.0;
    if (totalIncome > 0 && profile.debtPayments > 0) {
      final debtRatio = profile.debtPayments / totalIncome;
      if (debtRatio <= 0.1) {
        s4 = 90.0;
      } else if (debtRatio <= 0.3) {
        s4 = 70.0;
      } else if (debtRatio <= 0.5) {
        s4 = 40.0;
      } else {
        s4 = 10.0;
      }
    } else if (totalIncome == 0 && profile.debtPayments > 0) {
      s4 = 10.0;
    }

    // S5: Dependent Load Score (number of dependents)
    double s5 = 100.0;
    if (profile.totalDependents == 1 || profile.totalDependents == 2) {
      s5 = 85.0;
    } else if (profile.totalDependents == 3 || profile.totalDependents == 4) {
      s5 = 60.0;
    } else if (profile.totalDependents > 4) {
      s5 = 30.0;
    }

    // S6: Protection Readiness Score (BPJS + Insurance)
    double s6 = 10.0;
    if (profile.hasBpjs && profile.hasAdditionalInsurance) {
      s6 = 100.0;
    } else if (profile.hasBpjs) {
      s6 = 70.0;
    } else if (profile.hasAdditionalInsurance) {
      s6 = 50.0;
    }

    // S7: Shock Absorption Capacity Score (Surplus flow ratio)
    double s7 = 10.0;
    if (totalIncome > 0) {
      final surplus = totalIncome - profile.routineExpenses - profile.debtPayments;
      final surplusRatio = surplus / totalIncome;
      if (surplusRatio >= 0.3) {
        s7 = 100.0;
      } else if (surplusRatio >= 0.1) {
        s7 = 80.0;
      } else if (surplusRatio >= 0.0) {
        s7 = 50.0;
      }
    }

    // FVS Weighted Score calculation
    final score = (0.20 * s1) +
        (0.15 * s2) +
        (0.20 * s3) +
        (0.20 * s4) +
        (0.10 * s5) +
        (0.10 * s6) +
        (0.05 * s7);

    // Kategori skor
    String category;
    String description;

    if (score >= 80) {
      category = 'Aman';
      description = 'Keuangan keluarga Anda memiliki fondasi yang kuat dengan risiko rendah terhadap guncangan finansial tiba-tiba.';
    } else if (score >= 60) {
      category = 'Waspada';
      description = 'Kondisi cukup stabil, namun ada beberapa indikator lemah (seperti dana darurat atau cicilan tinggi) yang perlu diperbaiki.';
    } else if (score >= 40) {
      category = 'Rentan';
      description = 'Keuangan keluarga Anda rentan. Cashflow ketat atau tidak adanya dana darurat dapat memicu krisis finansial jika ada kejadian mendadak.';
    } else {
      category = 'Kritis';
      description = 'Kondisi keuangan kritis. Pendapatan tidak mencukupi pengeluaran, hutang berlebih, atau tidak adanya perlindungan kesehatan sama sekali.';
    }

    return FvsScore(
      score: score,
      s1: s1,
      s2: s2,
      s3: s3,
      s4: s4,
      s5: s5,
      s6: s6,
      s7: s7,
      category: category,
      description: description,
    );
  }
}
