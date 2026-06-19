import 'package:flutter/foundation.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/savings_vault_entity.dart';
import '../../domain/repositories/vault_repository.dart';

import '../../../../core/network/api_client.dart';

class VaultRepositoryImpl implements VaultRepository {
  final HiveService hiveService;
  final AuthRepository authRepository;
  final ApiClient apiClient;

  VaultRepositoryImpl({
    required this.hiveService,
    required this.authRepository,
    required this.apiClient,
  });

  static const String _vaultKey = LocalKeys.savingsVault;

  @override
  Future<List<SavingsVault>> getVaults() async {
    debugPrint('================ VAULT REPOSITORY GET VAULTS ================');
    debugPrint('VAULT KEY USED: $_vaultKey');

    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();

    debugPrint('VAULT currentUserId: ${currentUser?.userId}');
    debugPrint('VAULT currentEmail: ${currentUser?.email}');
    debugPrint('VAULT currentFamilyId: ${session?.currentFamilyId ?? currentUser?.familyId}');

    final rawData = hiveService.getData(_vaultKey);

    debugPrint('VAULT RAW TYPE: ${rawData.runtimeType}');
    debugPrint('VAULT RAW VALUE: $rawData');

    if (rawData == null) return [];

    final rawList = rawData is List ? rawData : <dynamic>[];

    debugPrint('VAULT RAW LIST COUNT: ${rawList.length}');

    final fallbackFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';
    final fallbackUserId = currentUser?.userId ?? '';
    final fallbackEmail = currentUser?.email ?? '';

    final vaults = rawList.map((item) {
      final json = Map<String, dynamic>.from(item as Map);

      return SavingsVault.fromJson(
        json,
        defaultFamilyId: fallbackFamilyId,
        defaultOwnerId: fallbackUserId,
        defaultOwnerEmail: fallbackEmail,
      );
    }).toList();

    debugPrint('VAULT MAPPED COUNT: ${vaults.length}');

    for (final vault in vaults) {
      debugPrint(
        'VAULT MAPPED => '
        'id=${vault.id}, '
        'name=${vault.name}, '
        'scope=${vault.scope.name}, '
        'familyId=${vault.familyId}, '
        'ownerUserId=${vault.ownerUserId}, '
        'ownerEmail=${vault.ownerEmail}',
      );
    }

    // Sync with backend API
    // Sync with API in background
    apiClient.dio.get('/vaults').catchError((e) => debugPrint('Sync error'));
    
    return vaults;
  }

  @override
  Future<void> saveVaults(List<SavingsVault> vaults) async {
    debugPrint('================ VAULT REPOSITORY SAVE VAULTS ================');
    debugPrint('VAULT KEY USED: $_vaultKey');
    debugPrint('VAULT SAVE COUNT: ${vaults.length}');

    final jsonList = vaults.map((vault) => vault.toJson()).toList();

    await hiveService.saveData(_vaultKey, jsonList);

    final verify = hiveService.getData(_vaultKey);
    debugPrint('VAULT VERIFY AFTER SAVE: $verify');
  }

  @override
  Future<void> createVault(SavingsVault vault) async {
    final vaults = await getVaults();

    debugPrint('VAULT COUNT BEFORE CREATE: ${vaults.length}');
    debugPrint(
      'CREATE VAULT => '
      'id=${vault.id}, '
      'name=${vault.name}, '
      'scope=${vault.scope.name}, '
      'familyId=${vault.familyId}, '
      'ownerUserId=${vault.ownerUserId}, '
      'ownerEmail=${vault.ownerEmail}',
    );

    // 1. Send to Backend
    try {
      await apiClient.dio.post('/vaults', data: {
        'name': vault.name,
        'targetAmount': vault.targetAmount,
        'savedAmount': vault.savedAmount,
        'deadline': vault.deadline?.toIso8601String(),
        'scope': vault.scope.name.toUpperCase(),
        'priority': vault.priority.name.toUpperCase(),
        'savingFrequency': vault.savingFrequency.name.toUpperCase(),
      });
    } catch (e) {
      debugPrint('Vault API Create Error: $e');
    }

    // 2. Save Locally
    final updatedVaults = [...vaults, vault];
    await saveVaults(updatedVaults);

    final afterSave = await getVaults();
    debugPrint('VAULT COUNT AFTER CREATE: ${afterSave.length}');
  }

  @override
  Future<void> updateVault(SavingsVault updatedVault) async {
    final vaults = await getVaults();

    final updatedVaults = vaults.map((vault) {
      if (vault.id == updatedVault.id) {
        return updatedVault;
      }
      return vault;
    }).toList();

    await saveVaults(updatedVaults);
  }
}
