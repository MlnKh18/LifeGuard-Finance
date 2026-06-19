import '../../domain/entities/profile_summary.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/domain/entities/family_account.dart';
import '../../../auth/domain/entities/family_invitation.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../savings_vault/domain/entities/savings_vault_entity.dart';
import '../../../community/domain/entities/community_post.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../literacy/domain/entities/literacy_module.dart';

import '../../../savings_vault/domain/repositories/vault_repository.dart';
import '../../../rewards/domain/repositories/reward_repository.dart';
import '../../../rewards/domain/entities/reward_point.dart';

import '../../../../core/network/api_client.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final VaultRepository vaultRepository;
  final RewardRepository rewardRepository;
  final ApiClient apiClient;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.vaultRepository,
    required this.rewardRepository,
    required this.apiClient,
  });

  @override
  Future<ProfileSummary> getProfileSummary() async {
    final data = await localDataSource.getProfileData();

    final familyProfileRaw = data['familyProfile'] as Map<dynamic, dynamic>? ?? {};
    final fvsScoreRaw = data['fvsScore'] as Map<dynamic, dynamic>? ?? {};
    final literacyData = data['literacyData'] as Map<dynamic, dynamic>? ?? {};
    final communityData = data['communityData'] as Map<dynamic, dynamic>? ?? {};
    final mockUser = data['mockUser'] as Map<dynamic, dynamic>? ?? {};

    // Get Auth Session and active user data
    final authSessionRaw = data['authSession'] as Map<dynamic, dynamic>?;
    AuthSession? session;
    if (authSessionRaw != null) {
      session = AuthSession.fromJson(authSessionRaw);
    }

    final usersListRaw = data['usersRaw'] as List<dynamic>? ?? [];
    AppUser? currentUser;
    if (session != null) {
      try {
        final userMap = usersListRaw.firstWhere((u) => (u as Map)['userId'] == session!.currentUserId);
        currentUser = AppUser.fromJson(userMap as Map<dynamic, dynamic>);
      } catch (_) {}
    }

    debugPrint('PROFILE currentUserId: ${currentUser?.userId}');
    debugPrint('PROFILE currentUserEmail: ${currentUser?.email}');
    debugPrint('PROFILE currentFamilyId: ${session?.currentFamilyId}');
    debugPrint('PROFILE currentRole: ${session?.currentUserRole}');

    final familiesListRaw = data['familiesRaw'] as List<dynamic>? ?? [];
    FamilyAccount? family;
    if (session != null) {
      try {
        final familyMap = familiesListRaw.firstWhere((f) => (f as Map)['familyId'] == session!.currentFamilyId);
        family = FamilyAccount.fromJson(familyMap as Map<dynamic, dynamic>);
      } catch (_) {}
    }

    List<AppUser> familyMembers = [];
    if (session != null) {
      familyMembers = usersListRaw
          .where((u) => (u as Map)['familyId'] == session!.currentFamilyId)
          .map((u) => AppUser.fromJson(u as Map<dynamic, dynamic>))
          .toList();
    }

    final invitationsListRaw = data['invitationsRaw'] as List<dynamic>? ?? [];
    List<FamilyInvitation> familyInvitations = [];
    if (session != null) {
      familyInvitations = invitationsListRaw
          .where((i) => (i as Map)['familyId'] == session!.currentFamilyId)
          .map((i) => FamilyInvitation.fromJson(i as Map<dynamic, dynamic>))
          .toList();
    }

    // Map profile values
    final fixedIncome = (familyProfileRaw['fixedIncome'] as num?)?.toDouble() ?? 0.0;
    final variableIncome = (familyProfileRaw['variableIncome'] as num?)?.toDouble() ?? 0.0;
    final routineExpenses = (familyProfileRaw['routineExpenses'] as num?)?.toDouble() ?? 0.0;
    final debtPayments = (familyProfileRaw['debtPayments'] as num?)?.toDouble() ?? 0.0;
    final liquidSavings = (familyProfileRaw['liquidSavings'] as num?)?.toDouble() ?? 0.0;
    final dependentsCount = (familyProfileRaw['totalDependents'] as num?)?.toInt() ?? 0;
    final hasBpjs = familyProfileRaw['hasBpjs'] as bool? ?? false;
    final hasInsurance = familyProfileRaw['hasAdditionalInsurance'] as bool? ?? false;

    FamilyFinanceProfile? familyProfile;
    if (familyProfileRaw.isNotEmpty) {
      familyProfile = FamilyFinanceProfile(
        fixedIncome: fixedIncome,
        variableIncome: variableIncome,
        routineExpenses: routineExpenses,
        debtPayments: debtPayments,
        liquidSavings: liquidSavings,
        totalDependents: dependentsCount,
        hasBpjs: hasBpjs,
        hasAdditionalInsurance: hasInsurance,
      );
    }

    // Map latest FVS Score
    FvsScore? latestFvs;
    if (fvsScoreRaw.isNotEmpty) {
      try {
        latestFvs = FvsScore.fromJson(Map<String, dynamic>.from(fvsScoreRaw));
      } catch (_) {}
    }

    final List<String> weakestIndicators = [];
    if (latestFvs != null) {
      final scores = {
        'Stabilitas Pendapatan (S1)': latestFvs.s1,
        'Rasio Pengeluaran (S2)': latestFvs.s2,
        'Dana Darurat (S3)': latestFvs.s3,
        'Beban Utang (S4)': latestFvs.s4,
        'Tanggungan Keluarga (S5)': latestFvs.s5,
        'Kesiapan Proteksi (S6)': latestFvs.s6,
        'Kapasitas Penyerapan Guncangan (S7)': latestFvs.s7,
      };
      final sortedKeys = scores.keys.toList()
        ..sort((a, b) => scores[a]!.compareTo(scores[b]!));
      for (var key in sortedKeys) {
        if (scores[key]! < 60) {
          weakestIndicators.add(key);
        }
      }
      if (weakestIndicators.isEmpty && sortedKeys.isNotEmpty) {
        weakestIndicators.add(sortedKeys.first);
      }
    }

    final String actualUserId = currentUser?.userId ?? session?.currentUserId ?? '';
    final String actualFamilyId = currentUser?.familyId ?? session?.currentFamilyId ?? '';

    // Map Vaults from VaultRepository directly to ensure Single Source of Truth
    final List<SavingsVault> allVaults = await vaultRepository.getVaults();

    debugPrint('PROFILE allVaults FROM VaultRepository count: ${allVaults.length}');
    for (final vault in allVaults) {
      debugPrint(
        'ALL VAULT => '
        'id=${vault.id}, '
        'name=${vault.name}, '
        'scope=${vault.scope.name}, '
        'familyId=${vault.familyId}, '
        'ownerUserId=${vault.ownerUserId}, '
        'ownerEmail=${vault.ownerEmail}, '
        'currentAmount=${vault.savedAmount}, '
        'targetAmount=${vault.targetAmount}',
      );
    }

    final familyVaults = allVaults.where((v) {
      final match = v.scope == SavingsVaultScope.family && v.familyId == actualFamilyId;
      debugPrint(
        'CHECK FAMILY VAULT ${v.name}: '
        'vault.familyId=${v.familyId}, '
        'currentFamilyId=$actualFamilyId, '
        'match=$match',
      );
      return match;
    }).toList();

    final personalVaults = allVaults.where((v) {
      final match = v.scope == SavingsVaultScope.personal && v.ownerUserId == actualUserId;
      debugPrint(
        'CHECK PERSONAL VAULT ${v.name}: '
        'vault.ownerUserId=${v.ownerUserId}, '
        'currentUserId=$actualUserId, '
        'match=$match',
      );
      return match;
    }).toList();

    final visibleVaults = [...familyVaults, ...personalVaults];

    debugPrint('PROFILE familyVaults count: ${familyVaults.length}');
    debugPrint('PROFILE personalVaults count: ${personalVaults.length}');
    debugPrint('PROFILE visibleVaults count: ${visibleVaults.length}');
    debugPrint('================ GET PROFILE SUMMARY END ================');

    double totalFamilyVaultTarget = 0.0;
    double totalFamilyVaultSaved = 0.0;
    for (var v in familyVaults) {
      totalFamilyVaultTarget += v.targetAmount;
      totalFamilyVaultSaved += v.savedAmount;
    }

    double totalPersonalVaultTarget = 0.0;
    double totalPersonalVaultSaved = 0.0;
    for (var v in personalVaults) {
      totalPersonalVaultTarget += v.targetAmount;
      totalPersonalVaultSaved += v.savedAmount;
    }

    // Map Literacy
    final readCount = (literacyData['readCount'] as num?)?.toInt() ?? 0;
    
    final List<LiteracyModule> mockModules = [
      const LiteracyModule(
        moduleId: 'edu-s3-1',
        title: 'Membangun Dana Darurat Keluarga',
        topic: 'Dana Darurat',
        relatedIndicator: 'Dana Darurat (S3)',
        summary: 'Pelajari cara menentukan target dana darurat berdasarkan kebutuhan keluarga.',
        content: 'Konten modul...',
        practicalTips: ['Mulai dari yang kecil.'],
        keyTakeaways: [],
        durationMinutes: 5,
        externalUrl: 'https://sikapiuangmu.ojk.go.id/',
        isRecommended: true,
      ),
      const LiteracyModule(
        moduleId: 'edu-s4-1',
        title: 'Mengendalikan Rasio Utang Keluarga',
        topic: 'Manajemen Utang',
        relatedIndicator: 'Beban Utang (S4)',
        summary: 'Strategi efektif mengelola dan melunasi utang konsumtif.',
        content: 'Konten modul...',
        practicalTips: ['Gunakan metode snowball.'],
        keyTakeaways: [],
        durationMinutes: 7,
        externalUrl: 'https://www.bi.go.id/id/edukasi/default.aspx',
        isRecommended: false,
      ),
      const LiteracyModule(
        moduleId: 'edu-s6-1',
        title: 'Pentingnya Asuransi Kesehatan',
        topic: 'Proteksi',
        relatedIndicator: 'Kesiapan Proteksi (S6)',
        summary: 'Memilih asuransi yang tepat untuk proteksi keluarga dari risiko kesehatan.',
        content: 'Konten modul...',
        practicalTips: ['Pastikan premi sesuai budget.'],
        keyTakeaways: [],
        durationMinutes: 6,
        externalUrl: 'https://sikapiuangmu.ojk.go.id/FrontEnd/CMS/Category/132',
        isRecommended: false,
      ),
      const LiteracyModule(
        moduleId: 'edu-s2-1',
        title: 'Mengatur Anggaran Rumah Tangga',
        topic: 'Anggaran',
        relatedIndicator: 'Rasio Pengeluaran (S2)',
        summary: 'Menerapkan formula 50-30-20 untuk pembagian gaji bulanan.',
        content: 'Konten modul...',
        practicalTips: ['Catat pengeluaran harian.'],
        keyTakeaways: [],
        durationMinutes: 4,
        externalUrl: null,
        isRecommended: false,
      ),
    ];

    List<LiteracyModule> recommendedLiteracyModules = [];
    if (weakestIndicators.isNotEmpty) {
      final weakest = weakestIndicators.first;
      final matched = mockModules.where((m) => m.relatedIndicator == weakest).toList();
      if (matched.isNotEmpty) {
        recommendedLiteracyModules = matched;
      }
    }
    
    if (recommendedLiteracyModules.isEmpty) {
      recommendedLiteracyModules = mockModules.where((m) => m.isRecommended).toList();
    }
    
    if (recommendedLiteracyModules.isEmpty && mockModules.isNotEmpty) {
      recommendedLiteracyModules = [mockModules.first];
    }

    final literacyProgress = [readCount, mockModules.length];

    // Map Community activity
    final communityPostsRaw = communityData['posts'] as List<dynamic>? ?? [];
    final List<CommunityPost> communityPosts = communityPostsRaw
        .map((p) => CommunityPost.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();

    final List<Map<String, dynamic>> communityComments = currentUser?.role == UserRole.headOfFamily
        ? [
            {
              'postTitle': 'Sarah L. - #SandwichGeneration',
              'content': 'Sangat setuju! Saya membagi pos tabungan menggunakan vault.',
              'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
            },
            {
              'postTitle': 'Reza K. - #EmergencyFund',
              'content': 'Tetap semangat! Mulai dari menyisihkan 5% pendapatan bulanan.',
              'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
            },
          ]
        : [];

    // Map Rewards
    final rewardSummary = await rewardRepository.getRewardSummary();
    final totalRewardPoints = rewardSummary.totalPoints;
    final activeBadge = rewardSummary.activeBadge?.badgeName ?? 'None';
    
    final List<Map<String, dynamic>> rewardTransactions = rewardSummary.transactions.map((t) => {
      'type': rewardActivityTypeLabel(t.activityType),
      'points': t.points,
      'date': t.createdAt,
    }).toList();

    // Map user roles & permissions from Backend
    bool isHead = currentUser?.role == UserRole.headOfFamily;
      // Sync with API in background
      apiClient.dio.get('/profile-summary/me').catchError((e) => debugPrint('Sync error'));
    
    return ProfileSummary(
      currentUser: currentUser,
      family: family,
      familyProfile: familyProfile,
      latestFvs: latestFvs,
      userName: currentUser?.fullName ?? mockUser['name'] as String? ?? 'Pengguna LifeGuard',
      email: currentUser?.email ?? mockUser['email'] as String? ?? 'Belum diatur',
      role: currentUser?.role ?? UserRole.headOfFamily,
      familyName: family?.familyName ?? 'Keluarga Baru',
      familyCode: family?.familyCode ?? '-',
      totalRewardPoints: totalRewardPoints,
      activeBadge: activeBadge,
      fixedIncome: fixedIncome,
      variableIncome: variableIncome,
      totalIncome: fixedIncome + variableIncome,
      monthlyExpense: routineExpenses,
      monthlyDebtPayment: debtPayments,
      liquidSavings: liquidSavings,
      dependentsCount: dependentsCount,
      hasBpjs: hasBpjs,
      hasInsurance: hasInsurance,
      latestFvsScore: latestFvs?.score ?? -1.0,
      latestFvsCategory: latestFvs?.category ?? 'Belum Tersedia',
      latestFvsCalculatedAt: latestFvs?.calculatedAt,
      weakestIndicators: weakestIndicators,
      allVaults: allVaults,
      familyVaults: familyVaults,
      personalVaults: personalVaults,
      visibleVaults: visibleVaults,
      totalFamilyVaultTarget: totalFamilyVaultTarget,
      totalFamilyVaultSaved: totalFamilyVaultSaved,
      totalPersonalVaultTarget: totalPersonalVaultTarget,
      totalPersonalVaultSaved: totalPersonalVaultSaved,
      familyVaultCount: familyVaults.length,
      personalVaultCount: personalVaults.length,
      literacyProgress: literacyProgress,
      recommendedLiteracyModules: recommendedLiteracyModules,
      communityPosts: communityPosts,
      communityComments: communityComments,
      familyMembers: familyMembers,
      familyInvitations: familyInvitations,
      rewardTransactions: rewardTransactions,
      canAccessCommunity: isHead,
      canManageFamilyMembers: isHead,
      canEditFamilyProfile: isHead,
      canDeleteFamilyData: isHead,
    );
  }

  @override
  Future<void> clearLocalProfileData() async {
    await localDataSource.clearLocalProfileData();
  }
}
