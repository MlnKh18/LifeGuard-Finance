class FVSScore {
  final String? scoreId;
  final String? profileId;
  final int totalScore; // 0 - 100
  final String category; // 'Aman', 'Waspada', 'Rentan', 'Kritis'
  
  // Breakdown scores (each 0 - 100)
  final int incomeStabilityScore;
  final int expenseRatioScore;
  final int emergencyFundScore;
  final int debtBurdenScore;
  final int dependentLoadScore;
  final int protectionReadinessScore;
  final int shockAbsorptionScore;
  final DateTime calculatedAt;

  FVSScore({
    this.scoreId,
    this.profileId,
    required this.totalScore,
    required this.category,
    required this.incomeStabilityScore,
    required this.expenseRatioScore,
    required this.emergencyFundScore,
    required this.debtBurdenScore,
    required this.dependentLoadScore,
    required this.protectionReadinessScore,
    required this.shockAbsorptionScore,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'score_id': scoreId,
      'profile_id': profileId,
      'total_score': totalScore,
      'category': category,
      'income_stability_score': incomeStabilityScore,
      'expense_ratio_score': expenseRatioScore,
      'emergency_fund_score': emergencyFundScore,
      'debt_burden_score': debtBurdenScore,
      'dependent_load_score': dependentLoadScore,
      'protection_readiness_score': protectionReadinessScore,
      'shock_absorption_score': shockAbsorptionScore,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  factory FVSScore.fromMap(Map<String, dynamic> map) {
    return FVSScore(
      scoreId: map['score_id'] as String?,
      profileId: map['profile_id'] as String?,
      totalScore: map['total_score'] as int,
      category: map['category'] as String,
      incomeStabilityScore: map['income_stability_score'] as int,
      expenseRatioScore: map['expense_ratio_score'] as int,
      emergencyFundScore: map['emergency_fund_score'] as int,
      debtBurdenScore: map['debt_burden_score'] as int,
      dependentLoadScore: map['dependent_load_score'] as int,
      protectionReadinessScore: map['protection_readiness_score'] as int,
      shockAbsorptionScore: map['shock_absorption_score'] as int,
      calculatedAt: DateTime.parse(map['calculated_at'] as String),
    );
  }
}
