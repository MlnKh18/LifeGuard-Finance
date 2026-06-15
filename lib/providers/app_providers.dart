import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/finance_profile.dart';
import '../data/models/fvs_score.dart';
import '../data/models/simulation.dart';
import '../data/models/recommendation.dart';
import '../data/repositories/finance_repository.dart';
import '../data/repositories/score_repository.dart';
import '../logic/scoring/fvs_scoring_engine.dart';
import '../logic/recommendation/recommendation_rules.dart';

// 1. Repository Providers
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository();
});

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

// 2. Profile State Notifier & Provider
class ProfileNotifier extends StateNotifier<FamilyFinanceProfile?> {
  final FinanceRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(null) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await _repository.getLatestProfile();
    state = profile;
    if (profile != null) {
      // If profile loaded, trigger FVS calculation
      _ref.read(fvsStateProvider.notifier).calculateAndSaveFvs(profile);
    }
  }

  Future<bool> saveProfile(FamilyFinanceProfile profile) async {
    final success = await _repository.saveProfile(profile);
    if (success) {
      state = profile;
      // Re-calculate FVS Score
      await _ref.read(fvsStateProvider.notifier).calculateAndSaveFvs(profile);
    }
    return success;
  }

  Future<void> clearProfile() async {
    state = null;
  }
}

final profileStateProvider = StateNotifierProvider<ProfileNotifier, FamilyFinanceProfile?>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return ProfileNotifier(repo, ref);
});

// 3. FVS Score Notifier & Provider
class FvsNotifier extends StateNotifier<FVSScore?> {
  final ScoreRepository _repository;

  FvsNotifier(this._repository) : super(null) {
    _loadLatestScore();
  }

  Future<void> _loadLatestScore() async {
    final history = await _repository.getScoreHistory();
    if (history.isNotEmpty) {
      state = history.first;
    }
  }

  Future<void> calculateAndSaveFvs(FamilyFinanceProfile profile) async {
    final score = FVSScoringEngine.calculate(profile);
    // Add profile_id to score
    final scoreWithProfile = FVSScore(
      scoreId: DateTime.now().millisecondsSinceEpoch.toString(),
      profileId: profile.profileId ?? 'current',
      totalScore: score.totalScore,
      category: score.category,
      incomeStabilityScore: score.incomeStabilityScore,
      expenseRatioScore: score.expenseRatioScore,
      emergencyFundScore: score.emergencyFundScore,
      debtBurdenScore: score.debtBurdenScore,
      dependentLoadScore: score.dependentLoadScore,
      protectionReadinessScore: score.protectionReadinessScore,
      shockAbsorptionScore: score.shockAbsorptionScore,
      calculatedAt: score.calculatedAt,
    );
    await _repository.saveScore(scoreWithProfile);
    state = scoreWithProfile;
  }

  Future<void> clearScore() async {
    state = null;
  }
}

final fvsStateProvider = StateNotifierProvider<FvsNotifier, FVSScore?>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  return FvsNotifier(repo);
});

// 4. Recommendations Provider (Derived State)
final recommendationsProvider = Provider<List<Recommendation>>((ref) {
  final profile = ref.watch(profileStateProvider);
  final score = ref.watch(fvsStateProvider);

  if (profile == null || score == null) {
    return [];
  }

  return RecommendationRules.generate(profile: profile, score: score);
});

// 5. Simulation History Notifier & Provider
class SimulationNotifier extends StateNotifier<List<ScenarioSimulation>> {
  final ScoreRepository _repository;

  SimulationNotifier(this._repository) : super([]) {
    loadSimulationHistory();
  }

  Future<void> loadSimulationHistory() async {
    final list = await _repository.getSimulationHistory();
    state = list;
  }

  Future<bool> addSimulation(ScenarioSimulation simulation) async {
    final success = await _repository.saveSimulation(simulation);
    if (success) {
      await loadSimulationHistory();
    }
    return success;
  }

  Future<void> clearSimulations() async {
    state = [];
  }
}

final simulationHistoryProvider = StateNotifierProvider<SimulationNotifier, List<ScenarioSimulation>>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  return SimulationNotifier(repo);
});

// 6. Global Reset Provider
final databaseResetProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // 1. Wipe SQLite
    final scoreRepo = ref.read(scoreRepositoryProvider);
    await scoreRepo.clearAllData();
    
    // 2. Clear Riverpod states
    ref.read(profileStateProvider.notifier).clearProfile();
    ref.read(fvsStateProvider.notifier).clearScore();
    ref.read(simulationHistoryProvider.notifier).clearSimulations();
  };
});
