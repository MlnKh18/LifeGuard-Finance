import '../../auth/domain/entities/user_role.dart';
import '../domain/entities/savings_vault_entity.dart';

class VaultPermissionHelper {
  static bool canViewVault({
    required SavingsVault vault,
    required String currentUserId,
    required String currentFamilyId,
  }) {
    if (vault.scope == SavingsVaultScope.family) {
      return vault.familyId == currentFamilyId;
    }

    if (vault.scope == SavingsVaultScope.personal) {
      return vault.ownerUserId == currentUserId;
    }

    return false;
  }

  static bool canEditVault({
    required SavingsVault vault,
    required String currentUserId,
    required UserRole currentRole,
  }) {
    if (vault.scope == SavingsVaultScope.personal) {
      return vault.ownerUserId == currentUserId;
    }

    if (vault.scope == SavingsVaultScope.family) {
      return currentRole == UserRole.headOfFamily;
    }

    return false;
  }
}
