import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/literacy_module.dart';
import '../../domain/repositories/literacy_repository.dart';
import '../mock_literacy_data.dart';

class LiteracyRepositoryImpl implements LiteracyRepository {
  final HiveService hiveService;

  LiteracyRepositoryImpl({required this.hiveService});

  @override
  List<LiteracyModule> getModules() => mockLiteracyModules;

  @override
  Future<Set<String>> getReadModuleIds() async {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.literacyProgress);
    return (raw?['readModuleIds'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? <String>{};
  }

  @override
  Future<void> markAsRead(String moduleId) async {
    final current = await getReadModuleIds();
    if (current.contains(moduleId)) return;
    final updated = {...current, moduleId};
    await hiveService.saveData(LocalKeys.literacyProgress, {
      'readCount': updated.length,
      'readModuleIds': updated.toList(),
    });
  }
}
