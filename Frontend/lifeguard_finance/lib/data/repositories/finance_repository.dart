import '../database/database_helper.dart';
import '../models/finance_profile.dart';

class FinanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> saveProfile(FamilyFinanceProfile profile) async {
    try {
      await _dbHelper.saveProfile(profile);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<FamilyFinanceProfile?> getLatestProfile() async {
    return await _dbHelper.getLatestProfile();
  }
}
