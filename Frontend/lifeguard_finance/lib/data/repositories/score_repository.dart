import '../database/database_helper.dart';
import '../models/fvs_score.dart';
import '../models/simulation.dart';

class ScoreRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> saveScore(FVSScore score) async {
    try {
      await _dbHelper.insertScore(score);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<FVSScore>> getScoreHistory() async {
    return await _dbHelper.getScoreHistory();
  }

  Future<bool> saveSimulation(ScenarioSimulation simulation) async {
    try {
      await _dbHelper.insertSimulation(simulation);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<ScenarioSimulation>> getSimulationHistory() async {
    return await _dbHelper.getSimulationHistory();
  }

  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
  }
}
