import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';

abstract class ProfileLocalDataSource {
  Future<Map<String, dynamic>> getProfileData();
  Future<void> clearLocalProfileData();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final HiveService hiveService;

  ProfileLocalDataSourceImpl({required this.hiveService});

  @override
  Future<Map<String, dynamic>> getProfileData() async {
    final familyProfile = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.familyProfile) ?? {};
    final fvsScore = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.fvsScore) ?? {};
    final vaultData = hiveService.getData<List<dynamic>>(LocalKeys.savingsVault) ?? [];
    final literacyData = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.literacyProgress) ?? {};
    final communityData = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.communityPosts) ?? {};
    final rewardData = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.rewardPoints) ?? {};
    final mockUser = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.mockUser) ?? {};

    return {
      'familyProfile': familyProfile,
      'fvsScore': fvsScore,
      'vaultData': vaultData,
      'literacyData': literacyData,
      'communityData': communityData,
      'rewardData': rewardData,
      'mockUser': mockUser,
    };
  }

  @override
  Future<void> clearLocalProfileData() async {
    await hiveService.clearAll();
  }
}
