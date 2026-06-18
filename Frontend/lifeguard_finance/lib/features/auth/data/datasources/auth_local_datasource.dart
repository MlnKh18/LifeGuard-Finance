import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/family_account.dart';
import '../../domain/entities/family_invitation.dart';

abstract class AuthLocalDataSource {
  HiveService get hiveService;

  Future<void> saveUser(AppUser user);
  Future<void> saveFamilyAccount(FamilyAccount familyAccount);
  Future<void> saveAuthSession(AuthSession session);
  Future<void> clearAuthSession();

  Future<AppUser?> getUser(String emailOrUsername);
  Future<FamilyAccount?> getFamilyAccount(String familyId);
  Future<FamilyAccount?> getFamilyAccountByCode(String familyCode);
  Future<AuthSession?> getCurrentSession();
  Future<List<AppUser>> getFamilyMembers(String familyId);

  Future<void> saveFamilyInvitation(FamilyInvitation invitation);
  Future<List<FamilyInvitation>> getFamilyInvitations(String familyId);
  Future<FamilyInvitation?> getFamilyInvitationByCode(String familyCode, String inviteCode);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
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
    final normalizedInput = emailOrUsername.trim().toLowerCase();
    try {
      final userMap = usersRaw.firstWhere(
        (u) => ((u as Map)['email'] as String).trim().toLowerCase() == normalizedInput,
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

  @override
  Future<FamilyAccount?> getFamilyAccountByCode(String familyCode) async {
    final familiesRaw = hiveService.getData<List<dynamic>>(LocalKeys.families) ?? [];
    final normalizedCode = familyCode.trim().toUpperCase();
    try {
      final familyMap = familiesRaw.firstWhere(
        (f) => ((f as Map)['familyCode'] as String).trim().toUpperCase() == normalizedCode,
      );
      return FamilyAccount.fromJson(familyMap as Map<dynamic, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveFamilyInvitation(FamilyInvitation invitation) async {
    final invitationsRaw = hiveService.getData<List<dynamic>>(LocalKeys.familyInvitations) ?? [];
    
    // Remove if exists to update
    invitationsRaw.removeWhere((i) => (i as Map)['invitationId'] == invitation.invitationId);
    invitationsRaw.add(invitation.toJson());
    
    await hiveService.saveData(LocalKeys.familyInvitations, invitationsRaw);
  }

  @override
  Future<List<FamilyInvitation>> getFamilyInvitations(String familyId) async {
    final invitationsRaw = hiveService.getData<List<dynamic>>(LocalKeys.familyInvitations) ?? [];
    return invitationsRaw
        .where((i) => (i as Map)['familyId'] == familyId)
        .map((i) => FamilyInvitation.fromJson(i as Map<dynamic, dynamic>))
        .toList();
  }

  @override
  Future<FamilyInvitation?> getFamilyInvitationByCode(String familyCode, String inviteCode) async {
    final family = await getFamilyAccountByCode(familyCode);
    if (family == null) return null;

    final invitationsRaw = hiveService.getData<List<dynamic>>(LocalKeys.familyInvitations) ?? [];
    final normalizedInviteCode = inviteCode.trim().toUpperCase();
    try {
      final invMap = invitationsRaw.firstWhere(
        (i) => (i as Map)['familyId'] == family.familyId && (i['inviteCode'] as String).trim().toUpperCase() == normalizedInviteCode,
      );
      return FamilyInvitation.fromJson(invMap as Map<dynamic, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
