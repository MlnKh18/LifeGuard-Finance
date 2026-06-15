import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/finance_profile.dart';
import '../data/models/fvs_score.dart';
import '../data/models/simulation.dart';
import '../data/models/recommendation.dart';
import '../data/repositories/finance_repository.dart';
import '../data/repositories/score_repository.dart';
import '../data/repositories/vault_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/database/database_helper.dart';
import '../logic/scoring/fvs_scoring_engine.dart';
import '../logic/recommendation/recommendation_rules.dart';

// 1. Repository Providers
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository();
});

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepository(DatabaseHelper.instance);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(DatabaseHelper.instance);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(DatabaseHelper.instance);
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
  final Ref _ref;

  FvsNotifier(this._repository, this._ref) : super(null) {
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

    // Trigger alert checks
    await _ref.read(notificationsProvider.notifier).checkAndGenerateAlerts(profile, scoreWithProfile);
  }

  Future<void> clearScore() async {
    state = null;
  }
}

final fvsStateProvider = StateNotifierProvider<FvsNotifier, FVSScore?>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  return FvsNotifier(repo, ref);
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

// 6. Savings Vault Notifier & Provider
class VaultNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final VaultRepository _repository;
  VaultNotifier(this._repository) : super([]) {
    loadVaults();
  }

  Future<void> loadVaults() async {
    final list = await _repository.fetchVaults();
    state = list;
  }

  Future<void> addVault(String goalType, double targetAmount, double currentAmount, int priority) async {
    final newVault = {
      'vault_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'goal_type': goalType,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'priority': priority,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _repository.addOrUpdateVault(newVault);
    await loadVaults();
  }

  Future<void> addFunds(String vaultId, double amount) async {
    final vault = state.firstWhere((v) => v['vault_id'] == vaultId);
    final updatedVault = Map<String, dynamic>.from(vault);
    updatedVault['current_amount'] = (updatedVault['current_amount'] as num).toDouble() + amount;
    updatedVault['updated_at'] = DateTime.now().toIso8601String();
    await _repository.addOrUpdateVault(updatedVault);
    await loadVaults();
  }

  Future<void> deleteVault(String vaultId) async {
    await _repository.removeVault(vaultId);
    await loadVaults();
  }

  void clearVaults() {
    state = [];
  }
}

final vaultsProvider = StateNotifierProvider<VaultNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(vaultRepositoryProvider);
  return VaultNotifier(repo);
});

// 7. Notification Notifier & Provider
class NotificationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final NotificationRepository _repository;
  NotificationNotifier(this._repository) : super([]) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final list = await _repository.fetchNotifications();
    state = list;
  }

  Future<void> addNotification(String type, String message) async {
    // Avoid duplicate notifications in simple demo
    final duplicate = state.any((n) => n['message'] == message);
    if (duplicate) return;

    final newNotif = {
      'notification_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'message': message,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _repository.addNotification(newNotif);
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> checkAndGenerateAlerts(FamilyFinanceProfile profile, FVSScore score) async {
    if (score.totalScore < 40) {
      await addNotification(
        'fvs_drop',
        'Peringatan Kritis: Skor FVS Anda di bawah 40 (${score.totalScore})! Kesehatan finansial keluarga Anda dalam kondisi kritis. Segera kurangi pengeluaran non-esensial.',
      );
    } else if (score.totalScore < 55) {
      await addNotification(
        'fvs_drop',
        'Peringatan Rentan: Skor FVS Anda rendah (${score.totalScore}). Disarankan untuk membangun dana darurat tambahan.',
      );
    }

    final dti = profile.monthlyIncome > 0 ? (profile.monthlyDebtPayment / profile.monthlyIncome) : 0.0;
    if (dti > 0.40) {
      await addNotification(
        'debt_warning',
        'Peringatan Utang: Rasio cicilan bulanan Anda sebesar ${(dti * 100).toStringAsFixed(0)}% telah melebihi batas aman 40%. Batasi pengambilan utang baru.',
      );
    }

    final monthsCoverage = profile.monthlyExpense > 0 ? (profile.liquidSavings / profile.monthlyExpense) : 99.0;
    if (monthsCoverage < 3.0) {
      await addNotification(
        'emergency_low',
        'Peringatan Dana Darurat: Tabungan likuid Anda hanya cukup untuk ${monthsCoverage.toStringAsFixed(1)} bulan pengeluaran rutin. Targetkan minimal 3-6 bulan.',
      );
    }
  }

  void clearNotifications() {
    state = [];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repo);
});

// 8. Expense Notifier & Provider (Machine Learning Anomaly Mock)
class ExpenseNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ExpenseRepository _repository;
  final Ref _ref;

  ExpenseNotifier(this._repository, this._ref) : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final list = await _repository.fetchExpenses();
    if (list.isEmpty) {
      // Seed initial dummy data for demo anomaly detection
      await _seedInitialExpenses();
    } else {
      state = list;
    }
  }

  Future<void> _seedInitialExpenses() async {
    final now = DateTime.now();
    final monthStr = now.toIso8601String().substring(0, 7);
    final dummy = [
      {
        'expense_id': 'd1',
        'category': 'Hiburan',
        'amount': 200000.0,
        'period_month': monthStr,
        'is_routine': 0,
        'is_anomaly': 0,
        'anomaly_severity': 'NONE',
        'created_at': now.subtract(const Duration(days: 20)).toIso8601String(),
      },
      {
        'expense_id': 'd2',
        'category': 'Hiburan',
        'amount': 250000.0,
        'period_month': monthStr,
        'is_routine': 0,
        'is_anomaly': 0,
        'anomaly_severity': 'NONE',
        'created_at': now.subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'expense_id': 'd3',
        'category': 'Makanan',
        'amount': 1200000.0,
        'period_month': monthStr,
        'is_routine': 1,
        'is_anomaly': 0,
        'anomaly_severity': 'NONE',
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];
    for (var exp in dummy) {
      await _repository.addExpense(exp);
    }
    final list = await _repository.fetchExpenses();
    state = list;
  }

  Future<void> addExpenseAndCheckAnomaly(String category, double amount, bool isRoutine) async {
    final categoryExpenses = state.where((e) => e['category'].toString().toUpperCase() == category.toUpperCase()).toList();
    
    int isAnomaly = 0;
    String anomalySeverity = 'NONE';
    
    if (categoryExpenses.length >= 2) {
      double sum = 0.0;
      for (var e in categoryExpenses) {
        sum += (e['amount'] as num).toDouble();
      }
      double avg = sum / categoryExpenses.length;
      
      if (amount > 1.6 * avg) {
        isAnomaly = 1;
        anomalySeverity = 'HIGH';
      } else if (amount > 1.3 * avg) {
        isAnomaly = 1;
        anomalySeverity = 'MEDIUM';
      }
    }

    final newExpense = {
      'expense_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': category,
      'amount': amount,
      'period_month': DateTime.now().toIso8601String().substring(0, 7),
      'is_routine': isRoutine ? 1 : 0,
      'is_anomaly': isAnomaly,
      'anomaly_severity': anomalySeverity,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _repository.addExpense(newExpense);
    await loadExpenses();

    if (isAnomaly == 1) {
      await _ref.read(notificationsProvider.notifier).addNotification(
        'anomaly',
        'Deteksi Anomali: Lonjakan pengeluaran tidak wajar pada kategori "$category" senilai Rp ${amount.toStringAsFixed(0)} (${anomalySeverity == 'HIGH' ? 'Sangat Tinggi' : 'Sedang'} dibanding rata-rata).',
      );
    }
  }

  void clearExpenses() {
    state = [];
  }
}

final expensesProvider = StateNotifierProvider<ExpenseNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return ExpenseNotifier(repo, ref);
});

// 9. Community Forum Mocking State
class CommunityPost {
  final String postId;
  final String title;
  final String category;
  final String content;
  final String author;
  final int supportCount;
  final int commentsCount;
  final DateTime createdAt;

  CommunityPost({
    required this.postId,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.supportCount,
    required this.commentsCount,
    required this.createdAt,
  });

  CommunityPost copyWith({
    int? supportCount,
    int? commentsCount,
  }) {
    return CommunityPost(
      postId: postId,
      title: title,
      category: category,
      content: content,
      author: author,
      supportCount: supportCount ?? this.supportCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
    );
  }
}

class CommunityNotifier extends StateNotifier<List<CommunityPost>> {
  CommunityNotifier() : super(_initialPosts);

  static final List<CommunityPost> _initialPosts = [
    CommunityPost(
      postId: '1',
      title: 'Generasi Sandwich: Bagaimana cara membagi pos orang tua dan anak?',
      category: 'Sandwich',
      content: 'Halo teman-teman, saya sedang kesulitan menyeimbangkan antara membayar cicilan rumah, membiayai sekolah anak, dan memberi bulanan untuk orang tua. Ada yang punya tips smart routing alokasi pendapatan?',
      author: 'Raka Permana',
      supportCount: 12,
      commentsCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    CommunityPost(
      postId: '2',
      title: 'Dana Darurat: Lebih baik disimpan di RDPU atau Tabungan Likuid biasa?',
      category: 'Emergency',
      content: 'Melihat skor FVS saya rendah di bagian dana darurat, saya ingin mulai disiplin menabung. Namun bingung instrumen apa yang paling cepat dicairkan saat krisis medis melanda.',
      author: 'Nadia Kartika',
      supportCount: 8,
      commentsCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CommunityPost(
      postId: '3',
      title: 'Kenaikan Suku Bunga KPR: Cara negosiasi ulang suku bunga?',
      category: 'Debt',
      content: 'Cicilan bulanan rumah saya melonjak karena masa promo bunga tetap habis. Apakah ada yang pernah mengajukan restrukturisasi cicilan ke bank?',
      author: 'Sari Wijaya',
      supportCount: 15,
      commentsCount: 7,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  void addPost(String title, String category, String content) {
    final newPost = CommunityPost(
      postId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      content: content,
      author: 'Anda (Pengguna)',
      supportCount: 0,
      commentsCount: 0,
      createdAt: DateTime.now(),
    );
    state = [newPost, ...state];
  }

  void supportPost(String postId) {
    state = state.map((post) {
      if (post.postId == postId) {
        return post.copyWith(supportCount: post.supportCount + 1);
      }
      return post;
    }).toList();
  }

  void addComment(String postId) {
    state = state.map((post) {
      if (post.postId == postId) {
        return post.copyWith(commentsCount: post.commentsCount + 1);
      }
      return post;
    }).toList();
  }

  void reset() {
    state = _initialPosts;
  }
}

final communityProvider = StateNotifierProvider<CommunityNotifier, List<CommunityPost>>((ref) {
  return CommunityNotifier();
});

// 10. Reward Points Notifier & Provider
class RewardPointsState {
  final int points;
  final String badgeLevel;

  RewardPointsState({required this.points, required this.badgeLevel});
}

class RewardPointsNotifier extends StateNotifier<RewardPointsState> {
  RewardPointsNotifier() : super(RewardPointsState(points: 35, badgeLevel: 'Sersan Finansial'));

  void addPoints(int value) {
    final newPoints = state.points + value;
    String badge = 'Sersan Finansial';
    if (newPoints >= 100) {
      badge = 'Pahlawan Finansial Keluarga';
    } else if (newPoints >= 60) {
      badge = 'Kapten Ketahanan';
    }
    state = RewardPointsState(points: newPoints, badgeLevel: badge);
  }

  void reset() {
    state = RewardPointsState(points: 35, badgeLevel: 'Sersan Finansial');
  }
}

final rewardPointsProvider = StateNotifierProvider<RewardPointsNotifier, RewardPointsState>((ref) {
  return RewardPointsNotifier();
});

// 11. Global Reset Provider
final databaseResetProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // 1. Wipe SQLite
    final scoreRepo = ref.read(scoreRepositoryProvider);
    await scoreRepo.clearAllData();
    
    // 2. Clear Riverpod states
    ref.read(profileStateProvider.notifier).clearProfile();
    ref.read(fvsStateProvider.notifier).clearScore();
    ref.read(simulationHistoryProvider.notifier).clearSimulations();
    ref.read(vaultsProvider.notifier).clearVaults();
    ref.read(notificationsProvider.notifier).clearNotifications();
    ref.read(expensesProvider.notifier).clearExpenses();
    ref.read(communityProvider.notifier).reset();
    ref.read(rewardPointsProvider.notifier).reset();
  };
});
