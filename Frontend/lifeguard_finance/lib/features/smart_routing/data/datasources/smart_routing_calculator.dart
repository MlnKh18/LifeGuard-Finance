import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../domain/entities/smart_routing_plan.dart';

class SmartRoutingCalculator {
  const SmartRoutingCalculator();

  SmartRoutingPlan calculate({
    required FamilyFinanceProfile profile,
    required String fvsCategory,
  }) {
    final totalIncome = profile.fixedIncome + profile.variableIncome;
    final percentages = _percentagesForCategory(fvsCategory);

    final allocations = percentages.entries
        .map((entry) => SmartRoutingAllocation(
              category: entry.key,
              percentage: entry.value,
              amount: totalIncome * (entry.value / 100),
            ))
        .toList();

    return SmartRoutingPlan(
      fvsCategory: fvsCategory,
      totalIncome: totalIncome,
      allocations: allocations,
      generatedAt: DateTime.now(),
    );
  }

  Map<String, double> _percentagesForCategory(String category) {
    switch (category) {
      case 'Aman':
        return const {
          'Kebutuhan Pokok': 45,
          'Cicilan': 20,
          'Dana Darurat': 10,
          'Pendidikan': 10,
          'Kesehatan': 5,
          'Tabungan Keluarga': 10,
        };
      case 'Waspada':
        return const {
          'Kebutuhan Pokok': 50,
          'Cicilan': 20,
          'Dana Darurat': 15,
          'Pendidikan': 5,
          'Kesehatan': 5,
          'Tabungan Keluarga': 5,
        };
      case 'Rentan':
        return const {
          'Kebutuhan Pokok': 55,
          'Cicilan': 25,
          'Dana Darurat': 15,
          'Pendidikan': 2.5,
          'Kesehatan': 2.5,
          'Tabungan Keluarga': 0,
        };
      default: // Kritis
        return const {
          'Kebutuhan Pokok': 60,
          'Cicilan': 25,
          'Dana Darurat': 10,
          'Pendidikan': 2.5,
          'Kesehatan': 2.5,
          'Tabungan Keluarga': 0,
        };
    }
  }
}
