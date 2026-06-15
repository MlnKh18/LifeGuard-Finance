import '../../data/models/finance_profile.dart';
import '../../data/models/simulation.dart';
import '../scoring/fvs_scoring_engine.dart';

class SimulationEngine {
  /// Simulates a financial crisis scenario and returns its projected outcome
  static ScenarioSimulation run({
    required FamilyFinanceProfile profile,
    required String scenarioType, // 'PHK', 'Medical', 'Cicilan', 'Inflasi'
    required int durationMonths,
    required double amount,
  }) {
    double projectedIncome = profile.monthlyIncome;
    double projectedExpense = profile.monthlyExpense;
    double projectedSavings = profile.liquidSavings;
    double projectedDebtPayment = profile.monthlyDebtPayment;
    
    double monthlyDeficit = 0.0;
    
    switch (scenarioType.toUpperCase()) {
      case 'PHK':
        // Loss of all income for the duration
        projectedIncome = 0.0;
        monthlyDeficit = projectedExpense; // Entire expenses become deficit
        // Deduct expenses from savings for the duration of job loss
        projectedSavings = (profile.liquidSavings - (projectedExpense * durationMonths))
            .clamp(0.0, double.infinity);
        break;
        
      case 'MEDICAL':
        // Sudden one-time medical cost, paid immediately from savings
        monthlyDeficit = amount;
        projectedSavings = (profile.liquidSavings - amount)
            .clamp(0.0, double.infinity);
        break;
        
      case 'CICILAN':
        // Installment increase (amount is the monthly increase rate)
        projectedDebtPayment = profile.monthlyDebtPayment + amount;
        projectedExpense = profile.monthlyExpense + amount;
        monthlyDeficit = amount;
        // Adjust savings based on duration of the increase
        projectedSavings = (profile.liquidSavings - (amount * durationMonths))
            .clamp(0.0, double.infinity);
        break;
        
      case 'INFLASI':
        // Essential food/cost inflation (amount represents percentage, e.g., 0.15 for 15%)
        double inflationCost = profile.essentialExpense * amount;
        projectedExpense = profile.monthlyExpense + inflationCost;
        monthlyDeficit = inflationCost;
        // Adjust savings based on duration
        projectedSavings = (profile.liquidSavings - (inflationCost * durationMonths))
            .clamp(0.0, double.infinity);
        break;

      case 'PENDIDIKAN':
        // Sudden education entry fee, paid immediately from savings
        monthlyDeficit = amount;
        projectedSavings = (profile.liquidSavings - amount)
            .clamp(0.0, double.infinity);
        break;

      case 'DEPENDENT':
        // Additional dependent adds monthly expenses and increases dependent count
        projectedExpense = profile.monthlyExpense + amount;
        monthlyDeficit = amount;
        projectedSavings = (profile.liquidSavings - (amount * durationMonths))
            .clamp(0.0, double.infinity);
        break;

      default:
        break;
    }

    // Create the projected profile to recalculate FVS Score
    final projectedProfile = profile.copyWith(
      monthlyIncome: projectedIncome,
      monthlyExpense: projectedExpense,
      liquidSavings: projectedSavings,
      monthlyDebtPayment: projectedDebtPayment,
      dependentsCount: scenarioType.toUpperCase() == 'DEPENDENT'
          ? profile.dependentsCount + 1
          : profile.dependentsCount,
    );

    // Calculate projected FVS
    final projectedFvs = FVSScoringEngine.calculate(projectedProfile);
    
    // Survival Months: how long can savings last with the new expense level
    double survivalMonths = projectedExpense > 0 
        ? (projectedSavings / projectedExpense) 
        : 99.9;

    return ScenarioSimulation(
      scenarioType: scenarioType,
      scenarioDurationMonths: durationMonths,
      scenarioAmount: amount,
      projectedScore: projectedFvs.totalScore,
      survivalMonths: double.parse(survivalMonths.toStringAsFixed(1)),
      monthlyDeficit: monthlyDeficit,
      createdAt: DateTime.now(),
    );
  }
}
