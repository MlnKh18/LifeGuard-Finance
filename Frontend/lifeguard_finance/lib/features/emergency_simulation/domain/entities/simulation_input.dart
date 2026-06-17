enum ScenarioType {
  lossOfIncome,       // PHK / Kehilangan Pendapatan
  medicalEmergency,   // Biaya Medis Mendadak
  interestRateIncrease, // Kenaikan Cicilan
  inflationNeeds,     // Inflasi Kebutuhan Pokok
  educationEmergency, // Biaya Pendidikan Mendadak
  increasedDependents // Bertambah Tanggungan Keluarga
}

class SimulationInput {
  final ScenarioType scenarioType;
  final double parameterValue; // Represents months, percentage, or currency depending on ScenarioType
  final double? secondaryParameterValue; // For inflation, this can represent the primary needs expense

  const SimulationInput({
    required this.scenarioType,
    required this.parameterValue,
    this.secondaryParameterValue,
  });
}
