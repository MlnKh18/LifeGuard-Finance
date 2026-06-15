import '../../data/models/finance_profile.dart';
import '../../data/models/fvs_score.dart';
import '../../constants/app_colors.dart';

class FVSScoringEngine {
  /// Calculates FVS Score based on user's Financial Profile
  static FVSScore calculate(FamilyFinanceProfile profile) {
    // 1. Income Stability Score (Weight: 15%)
    final int incomeStability = profile.incomeType.toLowerCase() == 'tetap' ? 100 : 60;

    // 2. Expense Ratio Score (Weight: 15%)
    // Compares monthly expenses against total income
    final double expenseRatio = profile.monthlyIncome > 0 
        ? (profile.monthlyExpense / profile.monthlyIncome) 
        : 1.0;
    int expenseScore;
    if (expenseRatio <= 0.50) {
      expenseScore = 100;
    } else if (expenseRatio <= 0.70) {
      expenseScore = 80;
    } else if (expenseRatio <= 0.90) {
      expenseScore = 50;
    } else {
      expenseScore = 20;
    }

    // 3. Emergency Fund Score (Weight: 25%)
    // Measures emergency fund in terms of expense coverage months
    final double emergencyMonths = profile.monthlyExpense > 0 
        ? (profile.liquidSavings / profile.monthlyExpense) 
        : 0.0;
    int emergencyScore;
    if (emergencyMonths >= 6.0) {
      emergencyScore = 100;
    } else if (emergencyMonths >= 3.0) {
      emergencyScore = 75;
    } else if (emergencyMonths >= 1.0) {
      emergencyScore = 40;
    } else {
      emergencyScore = 10;
    }

    // 4. Debt Burden Score (Weight: 20%)
    // Measures monthly debt payment to income ratio (DBR)
    final double debtBurdenRatio = profile.monthlyIncome > 0 
        ? (profile.monthlyDebtPayment / profile.monthlyIncome) 
        : 0.0;
    int debtScore;
    if (profile.totalDebt <= 0 && profile.monthlyDebtPayment <= 0) {
      debtScore = 100; // No debt is ideal for low vulnerability
    } else if (debtBurdenRatio <= 0.30) {
      debtScore = 80;
    } else if (debtBurdenRatio <= 0.40) {
      debtScore = 50;
    } else if (debtBurdenRatio <= 0.50) {
      debtScore = 30;
    } else {
      debtScore = 10;
    }

    // 5. Dependent Load Score (Weight: 10%)
    // Evaluates dependent stress, adjusting for Generation Sandwich pressure
    int dependentScore;
    if (profile.dependentsCount == 0) {
      dependentScore = 100;
    } else if (profile.dependentsCount <= 2) {
      dependentScore = 80;
    } else if (profile.dependentsCount <= 4) {
      dependentScore = 50;
    } else {
      dependentScore = 25;
    }
    
    // Sandwich generation deducts additional safety points
    if (profile.householdType.toLowerCase() == 'sandwich') {
      dependentScore = (dependentScore - 15).clamp(10, 100);
    }

    // 6. Protection Readiness Score (Weight: 10%)
    // Checks for basic health (BPJS) and life protection
    int protectionScore;
    if (profile.hasHealthProtection && profile.hasLifeProtection) {
      protectionScore = 100;
    } else if (profile.hasHealthProtection) {
      protectionScore = 80; // Standard BPJS is high priority
    } else if (profile.hasLifeProtection) {
      protectionScore = 40;
    } else {
      protectionScore = 10;
    }

    // 7. Shock Absorption Score (Weight: 5%)
    // Synthetic metric of general resilience to guncangan financial
    // Combines savings rate and emergency buffer
    double savingRate = profile.monthlyIncome > 0 
        ? (profile.monthlyIncome - profile.monthlyExpense) / profile.monthlyIncome 
        : -1.0;
    int shockScore = ((emergencyScore * 0.4) + (expenseScore * 0.3) + (debtScore * 0.3)).round();
    if (savingRate < 0) {
      // If deficit monthly, shock capacity drops by half
      shockScore = (shockScore * 0.5).round().clamp(10, 100);
    }

    // Weighted Total Score calculation
    double weightedTotal = 
        (incomeStability * 0.15) +
        (expenseScore * 0.15) +
        (emergencyScore * 0.25) +
        (debtScore * 0.20) +
        (dependentScore * 0.10) +
        (protectionScore * 0.10) +
        (shockScore * 0.05);

    int finalScore = weightedTotal.round().clamp(0, 100);
    String category = AppColors.getScoreCategory(finalScore);

    return FVSScore(
      totalScore: finalScore,
      category: category,
      incomeStabilityScore: incomeStability,
      expenseRatioScore: expenseScore,
      emergencyFundScore: emergencyScore,
      debtBurdenScore: debtScore,
      dependentLoadScore: dependentScore,
      protectionReadinessScore: protectionScore,
      shockAbsorptionScore: shockScore,
      calculatedAt: DateTime.now(),
    );
  }
}
