class ScenarioSimulation {
  final String? simulationId;
  final String? profileId;
  final String scenarioType; // 'PHK', 'Medical', 'Cicilan', 'Inflasi'
  final int scenarioDurationMonths;
  final double scenarioAmount;
  final int projectedScore;
  final double survivalMonths;
  final double monthlyDeficit;
  final DateTime createdAt;

  ScenarioSimulation({
    this.simulationId,
    this.profileId,
    required this.scenarioType,
    required this.scenarioDurationMonths,
    required this.scenarioAmount,
    required this.projectedScore,
    required this.survivalMonths,
    required this.monthlyDeficit,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'simulation_id': simulationId,
      'profile_id': profileId,
      'scenario_type': scenarioType,
      'scenario_duration_months': scenarioDurationMonths,
      'scenario_amount': scenarioAmount,
      'projected_score': projectedScore,
      'survival_months': survivalMonths,
      'monthly_deficit': monthlyDeficit,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScenarioSimulation.fromMap(Map<String, dynamic> map) {
    return ScenarioSimulation(
      simulationId: map['simulation_id'] as String?,
      profileId: map['profile_id'] as String?,
      scenarioType: map['scenario_type'] as String,
      scenarioDurationMonths: map['scenario_duration_months'] as int,
      scenarioAmount: (map['scenario_amount'] as num).toDouble(),
      projectedScore: map['projected_score'] as int,
      survivalMonths: (map['survival_months'] as num).toDouble(),
      monthlyDeficit: (map['monthly_deficit'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
