import '../entities/savings_vault_entity.dart';

abstract class VaultRepository {
  Future<List<SavingsVault>> getVaults();
  Future<void> saveVaults(List<SavingsVault> vaults);
  Future<void> createVault(SavingsVault vault);
  Future<void> updateVault(SavingsVault vault);
}
