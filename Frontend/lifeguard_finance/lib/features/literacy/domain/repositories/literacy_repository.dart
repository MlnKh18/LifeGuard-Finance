import '../entities/literacy_module.dart';

abstract class LiteracyRepository {
  List<LiteracyModule> getModules();
  Future<Set<String>> getReadModuleIds();
  Future<void> markAsRead(String moduleId);
}
