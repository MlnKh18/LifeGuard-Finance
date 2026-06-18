import '../entities/app_user.dart';
import '../entities/auth_session.dart';
import '../entities/family_invitation.dart';
import '../entities/family_account.dart';

abstract class AuthRepository {
  Future<void> registerHeadOfFamily({
    required String fullName,
    required String email,
    required String password,
    required String familyName,
    String phoneNumber = '',
  });

  Future<AppUser> login(String email, String password);
  
  Future<void> logout();

  Future<AuthSession?> getCurrentSession();
  AuthSession? getCachedSession();
  
  Future<AppUser?> getCurrentUser();
  Future<bool> checkIsFamilyProfileCompleted();

  Future<String> inviteFamilyMember({
    required String fullName,
    required String email,
    required String relation,
    required bool isActive,
  });

  Future<void> activateFamilyMemberInvitation({
    required String email,
    required String familyCode,
    required String inviteCode,
    required String newPassword,
  });

  Future<List<AppUser>> getFamilyMembers();
  
  Future<List<FamilyInvitation>> getFamilyInvitations();
  
  Future<bool> checkEmailAlreadyRegistered(String email);

  Future<FamilyAccount?> getFamilyAccount();
}
