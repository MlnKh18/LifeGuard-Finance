class FamilyFinanceProfile {
  final String? profileId;
  final double monthlyIncome;
  final double monthlyExpense;
  final double essentialExpense;
  final double nonEssentialExpense;
  final double liquidSavings;
  final double totalDebt;
  final double monthlyDebtPayment;
  final int dependentsCount;
  final bool hasHealthProtection;
  final bool hasLifeProtection;
  final String incomeType; // 'Tetap', 'Tidak Tetap'
  final String householdType; // 'Lajang', 'Menikah', 'Sandwich'
  final String ageRange;
  final DateTime createdAt;

  FamilyFinanceProfile({
    this.profileId,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.essentialExpense,
    required this.nonEssentialExpense,
    required this.liquidSavings,
    required this.totalDebt,
    required this.monthlyDebtPayment,
    required this.dependentsCount,
    required this.hasHealthProtection,
    required this.hasLifeProtection,
    required this.incomeType,
    required this.householdType,
    required this.ageRange,
    required this.createdAt,
  });

  // Calculate some helper properties
  double get savingRate => monthlyIncome > 0 ? (monthlyIncome - monthlyExpense) / monthlyIncome : 0.0;
  double get debtToIncomeRatio => monthlyIncome > 0 ? monthlyDebtPayment / monthlyIncome : 0.0;
  double get emergencyFundMonths => monthlyExpense > 0 ? liquidSavings / monthlyExpense : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'monthly_income': monthlyIncome,
      'monthly_expense': monthlyExpense,
      'essential_expense': essentialExpense,
      'non_essential_expense': nonEssentialExpense,
      'liquid_savings': liquidSavings,
      'total_debt': totalDebt,
      'monthly_debt_payment': monthlyDebtPayment,
      'dependents_count': dependentsCount,
      'has_health_protection': hasHealthProtection ? 1 : 0,
      'has_life_protection': hasLifeProtection ? 1 : 0,
      'income_type': incomeType,
      'household_type': householdType,
      'age_range': ageRange,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FamilyFinanceProfile.fromMap(Map<String, dynamic> map) {
    return FamilyFinanceProfile(
      profileId: map['profile_id'] as String?,
      monthlyIncome: (map['monthly_income'] as num).toDouble(),
      monthlyExpense: (map['monthly_expense'] as num).toDouble(),
      essentialExpense: (map['essential_expense'] as num).toDouble(),
      nonEssentialExpense: (map['non_essential_expense'] as num).toDouble(),
      liquidSavings: (map['liquid_savings'] as num).toDouble(),
      totalDebt: (map['total_debt'] as num).toDouble(),
      monthlyDebtPayment: (map['monthly_debt_payment'] as num).toDouble(),
      dependentsCount: map['dependents_count'] as int,
      hasHealthProtection: map['has_health_protection'] == 1,
      hasLifeProtection: map['has_life_protection'] == 1,
      incomeType: map['income_type'] as String,
      householdType: map['household_type'] as String,
      ageRange: map['age_range'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // CopyWith helper
  FamilyFinanceProfile copyWith({
    String? profileId,
    double? monthlyIncome,
    double? monthlyExpense,
    double? essentialExpense,
    double? nonEssentialExpense,
    double? liquidSavings,
    double? totalDebt,
    double? monthlyDebtPayment,
    int? dependentsCount,
    bool? hasHealthProtection,
    bool? hasLifeProtection,
    String? incomeType,
    String? householdType,
    String? ageRange,
    DateTime? createdAt,
  }) {
    return FamilyFinanceProfile(
      profileId: profileId ?? this.profileId,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      essentialExpense: essentialExpense ?? this.essentialExpense,
      nonEssentialExpense: nonEssentialExpense ?? this.nonEssentialExpense,
      liquidSavings: liquidSavings ?? this.liquidSavings,
      totalDebt: totalDebt ?? this.totalDebt,
      monthlyDebtPayment: monthlyDebtPayment ?? this.monthlyDebtPayment,
      dependentsCount: dependentsCount ?? this.dependentsCount,
      hasHealthProtection: hasHealthProtection ?? this.hasHealthProtection,
      hasLifeProtection: hasLifeProtection ?? this.hasLifeProtection,
      incomeType: incomeType ?? this.incomeType,
      householdType: householdType ?? this.householdType,
      ageRange: ageRange ?? this.ageRange,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
