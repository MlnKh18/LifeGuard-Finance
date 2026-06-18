import '../../domain/entities/profile_summary.dart';
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

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<ProfileSummary> getProfileSummary() async {
    final data = await localDataSource.getProfileData();

    final familyProfileRaw = data['familyProfile'] as Map<dynamic, dynamic>? ?? {};
    final fvsScoreRaw = data['fvsScore'] as Map<dynamic, dynamic>? ?? {};
    final vaultDataRaw = data['vaultData'] as List<dynamic>? ?? [];
    final literacyData = data['literacyData'] as Map<dynamic, dynamic>? ?? {};
    final communityData = data['communityData'] as Map<dynamic, dynamic>? ?? {};
    final rewardData = data['rewardData'] as Map<dynamic, dynamic>? ?? {};
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

    // Map Vaults
    final List<SavingsVault> vaults = vaultDataRaw
        .map((e) => SavingsVault.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // Map Literacy
    final readCount = (literacyData['readCount'] as num?)?.toInt() ?? 0;
    final List<Map<String, dynamic>> recommendedModules = [
      {
        'title': 'Dasar Manajemen Dana Darurat',
        'indicator': 'Dana Darurat (S3)',
        'read': readCount > 0,
      },
      {
        'title': 'Mengendalikan Rasio Utang Keluarga',
        'indicator': 'Beban Utang (S4)',
        'read': readCount > 1,
      },
      {
        'title': 'Pentingnya Proteksi Asuransi Kesehatan',
        'indicator': 'Kesiapan Proteksi (S6)',
        'read': readCount > 2,
      },
      {
        'title': 'Mengatur Anggaran Rumah Tangga',
        'indicator': 'Rasio Pengeluaran (S2)',
        'read': false,
      },
      {
        'title': 'Investasi Reksa Dana untuk Pemula',
        'indicator': 'Kapasitas Penyerapan Guncangan (S7)',
        'read': false,
      },
    ];

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
    final totalRewardPoints = (rewardData['points'] as num?)?.toInt() ?? 120;
    final activeBadge = rewardData['badge'] as String? ?? 'Financial Guardian';
    final List<Map<String, dynamic>> rewardTransactions = [
      {
        'type': 'Menyelesaikan FVS Kalkulator',
        'points': 50,
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'type': 'Membaca Modul Literasi Finansial',
        'points': 20,
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'type': 'Membuat Target Pos Dana Darurat',
        'points': 50,
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    // Map user roles & permissions
    final isHead = currentUser?.role == UserRole.headOfFamily;

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
      vaults: vaults,
      literacyProgress: [readCount, recommendedModules.length],
      recommendedLiteracyModules: recommendedModules,
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
