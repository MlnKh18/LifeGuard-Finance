import '../entities/literacy_module.dart';
import '../entities/literacy_summary.dart';
import '../entities/user_literacy_progress.dart';

abstract class LiteracyRepository {
  Future<List<LiteracyModule>> getModules();
  Future<LiteracyModule?> getModuleById(String moduleId);
  Future<LiteracySummary> getLiteracySummary(List<String> weakestIndicators);
  Future<void> markModuleAsRead(String moduleId);
  Future<List<UserLiteracyProgress>> getUserProgress();
  Future<LiteracyModule?> getRecommendedModule(List<String> weakestIndicators);
}
