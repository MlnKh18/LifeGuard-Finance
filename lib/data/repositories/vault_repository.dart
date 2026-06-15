import '../database/database_helper.dart';

class VaultRepository {
  final DatabaseHelper _dbHelper;

  VaultRepository(this._dbHelper);

  Future<List<Map<String, dynamic>>> fetchVaults() async {
    return await _dbHelper.getVaults();
  }

  Future<void> addOrUpdateVault(Map<String, dynamic> vaultMap) async {
    await _dbHelper.saveVault(vaultMap);
  }

  Future<void> removeVault(String vaultId) async {
    await _dbHelper.deleteVault(vaultId);
  }
}
