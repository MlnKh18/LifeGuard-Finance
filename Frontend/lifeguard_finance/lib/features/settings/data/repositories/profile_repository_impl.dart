import '../../domain/entities/profile_summary.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<ProfileSummary> getProfileSummary() async {
    final data = await localDataSource.getProfileData();

    final familyProfile = data['familyProfile'] as Map<dynamic, dynamic>? ?? {};
    final fvsScore = data['fvsScore'] as Map<dynamic, dynamic>? ?? {};
    final vaultList = data['vaultData'] as List<dynamic>? ?? [];
    final literacyData = data['literacyData'] as Map<dynamic, dynamic>? ?? {};
    final communityData = data['communityData'] as Map<dynamic, dynamic>? ?? {};
    final rewardData = data['rewardData'] as Map<dynamic, dynamic>? ?? {};
    final mockUser = data['mockUser'] as Map<dynamic, dynamic>? ?? {};

    final fixedIncome = (familyProfile['fixedIncome'] as num?)?.toDouble() ?? 0.0;
    final variableIncome = (familyProfile['variableIncome'] as num?)?.toDouble() ?? 0.0;

    double totalVaultSaved = 0.0;
    double totalVaultTarget = 0.0;
    for (var vault in vaultList) {
      if (vault is Map) {
        totalVaultSaved += (vault['currentAmount'] as num?)?.toDouble() ?? 0.0;
        totalVaultTarget += (vault['targetAmount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    double averageVaultProgress = totalVaultTarget > 0 ? (totalVaultSaved / totalVaultTarget) : 0.0;

    return ProfileSummary(
      userName: mockUser['name'] as String? ?? 'Pengguna LifeGuard',
      email: mockUser['email'] as String? ?? 'Belum diatur',
      totalRewardPoints: (rewardData['points'] as num?)?.toInt() ?? 0,
      activeBadge: rewardData['badge'] as String? ?? 'Starter Saver',
      
      fixedIncome: fixedIncome,
      variableIncome: variableIncome,
      totalIncome: fixedIncome + variableIncome,
      monthlyExpense: (familyProfile['routineExpense'] as num?)?.toDouble() ?? 0.0,
      monthlyDebtPayment: (familyProfile['debtInstallment'] as num?)?.toDouble() ?? 0.0,
      liquidSavings: (familyProfile['liquidSavings'] as num?)?.toDouble() ?? 0.0,
      dependentsCount: (familyProfile['dependents'] as num?)?.toInt() ?? 0,
      hasBpjs: familyProfile['hasBpjs'] as bool? ?? false,
      hasInsurance: familyProfile['hasAdditionalInsurance'] as bool? ?? false,
      
      latestFvsScore: (fvsScore['totalScore'] as num?)?.toDouble() ?? -1.0,
      latestFvsCategory: fvsScore['category'] as String? ?? 'Belum Tersedia',
      
      vaultCount: vaultList.length,
      totalVaultTarget: totalVaultTarget,
      totalVaultSaved: totalVaultSaved,
      averageVaultProgress: averageVaultProgress,
      
      literacyReadCount: (literacyData['readCount'] as num?)?.toInt() ?? 0,
      literacyTotalCount: (literacyData['totalCount'] as num?)?.toInt() ?? 0,
      
      communityPostCount: (communityData['postCount'] as num?)?.toInt() ?? 0,
      communityCommentCount: (communityData['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> clearLocalProfileData() async {
    await localDataSource.clearLocalProfileData();
  }
}
