import '../domain/entities/user_role.dart';

class PermissionHelper {
  PermissionHelper._();

  static bool isHeadOfFamily(UserRole role) => role == UserRole.headOfFamily;
  static bool isFamilyMember(UserRole role) => role == UserRole.familyMember;

  static bool canAccessCommunity(UserRole role) => isHeadOfFamily(role);
  static bool canManageFamilyMembers(UserRole role) => isHeadOfFamily(role);
  static bool canEditFamilyFinanceProfile(UserRole role) => isHeadOfFamily(role);
  static bool canDeleteLocalData(UserRole role) => isHeadOfFamily(role);
  
  static bool canViewFamilyDashboard(UserRole role) => true; // Both can view
}
