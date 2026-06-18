import '../entities/app_user.dart';
import '../entities/auth_session.dart';

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
  
  Future<AppUser?> getCurrentUser();

  Future<void> addFamilyMember({
    required String fullName,
    required String email,
    required String password,
    required String relation,
    required bool isActive,
  });

  Future<List<AppUser>> getFamilyMembers();
}
