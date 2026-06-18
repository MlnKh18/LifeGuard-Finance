import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/family_account.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(AppUser user);
  Future<void> saveFamilyAccount(FamilyAccount familyAccount);
  Future<void> saveAuthSession(AuthSession session);
  Future<void> clearAuthSession();

  Future<AppUser?> getUser(String emailOrUsername);
  Future<FamilyAccount?> getFamilyAccount(String familyId);
  Future<AuthSession?> getCurrentSession();
  Future<List<AppUser>> getFamilyMembers(String familyId);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveService hiveService;

  AuthLocalDataSourceImpl({required this.hiveService});

  @override
  Future<void> saveUser(AppUser user) async {
    final usersRaw = hiveService.getData<List<dynamic>>(LocalKeys.users) ?? [];
    
    // Remove if exists to update
    usersRaw.removeWhere((u) => (u as Map)['email'] == user.email);
    usersRaw.add(user.toJson());
    
    await hiveService.saveData(LocalKeys.users, usersRaw);
  }

  @override
  Future<void> saveFamilyAccount(FamilyAccount familyAccount) async {
    final familiesRaw = hiveService.getData<List<dynamic>>(LocalKeys.families) ?? [];
    
    // Remove if exists to update
    familiesRaw.removeWhere((f) => (f as Map)['familyId'] == familyAccount.familyId);
    familiesRaw.add(familyAccount.toJson());
    
    await hiveService.saveData(LocalKeys.families, familiesRaw);
  }

  @override
  Future<void> saveAuthSession(AuthSession session) async {
    await hiveService.saveData(LocalKeys.authSession, session.toJson());
  }

  @override
  Future<void> clearAuthSession() async {
    await hiveService.deleteData(LocalKeys.authSession);
  }

  @override
  Future<AppUser?> getUser(String emailOrUsername) async {
    final usersRaw = hiveService.getData<List<dynamic>>(LocalKeys.users) ?? [];
    try {
      final userMap = usersRaw.firstWhere(
        (u) => (u as Map)['email'] == emailOrUsername,
      );
      return AppUser.fromJson(userMap as Map<dynamic, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FamilyAccount?> getFamilyAccount(String familyId) async {
    final familiesRaw = hiveService.getData<List<dynamic>>(LocalKeys.families) ?? [];
    try {
      final familyMap = familiesRaw.firstWhere(
        (f) => (f as Map)['familyId'] == familyId,
      );
      return FamilyAccount.fromJson(familyMap as Map<dynamic, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    final sessionMap = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.authSession);
    if (sessionMap != null) {
      return AuthSession.fromJson(sessionMap);
    }
    return null;
  }

  @override
  Future<List<AppUser>> getFamilyMembers(String familyId) async {
    final usersRaw = hiveService.getData<List<dynamic>>(LocalKeys.users) ?? [];
    return usersRaw
        .where((u) => (u as Map)['familyId'] == familyId)
        .map((u) => AppUser.fromJson(u as Map<dynamic, dynamic>))
        .toList();
  }
}
