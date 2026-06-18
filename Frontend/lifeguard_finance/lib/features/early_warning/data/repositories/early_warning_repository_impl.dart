import 'package:flutter/foundation.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/early_warning.dart';
import '../../domain/repositories/early_warning_repository.dart';

class EarlyWarningRepositoryImpl implements EarlyWarningRepository {
  final HiveService hiveService;
  final AuthRepository authRepository;

  EarlyWarningRepositoryImpl({
    required this.hiveService,
    required this.authRepository,
  });

  @override
  Future<List<EarlyWarning>> getWarnings() async {
    final session = authRepository.getCachedSession();
    if (session == null) return [];

    final rawList = await hiveService.getData(LocalKeys.earlyWarnings);
    if (rawList == null || rawList is! List) return [];

    final List<EarlyWarning> allWarnings = rawList
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => EarlyWarning.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return allWarnings.where((w) => w.familyId == session.currentFamilyId).toList();
  }

  @override
  Future<void> createWarning(EarlyWarning warning) async {
    final session = authRepository.getCachedSession();
    if (session == null) return;

    final rawList = await hiveService.getData(LocalKeys.earlyWarnings);
    List<Map<String, dynamic>> updatedList = [];

    if (rawList != null && rawList is List) {
      updatedList = rawList
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    // Check if duplicate (same sourceId and type)
    if (warning.sourceId != null) {
      final isDuplicate = updatedList.any((e) => e['sourceId'] == warning.sourceId && e['source'] == warning.source.name);
      if (isDuplicate) return;
    }

    updatedList.add(warning.toJson());
    await hiveService.saveData(LocalKeys.earlyWarnings, updatedList);

    debugPrint('================ CREATE EARLY WARNING ================');
    debugPrint('title: ${warning.title}');
    debugPrint('severity: ${warning.severity}');
    debugPrint('source: ${warning.source}');
  }

  @override
  Future<void> markAsRead(String warningId) async {
    final rawList = await hiveService.getData(LocalKeys.earlyWarnings);
    if (rawList == null || rawList is! List) return;

    final updatedList = rawList.map((e) {
      if (e is Map) {
        final map = Map<String, dynamic>.from(e);
        if (map['warningId'] == warningId) {
          map['isRead'] = true;
        }
        return map;
      }
      return e;
    }).toList();

    await hiveService.saveData(LocalKeys.earlyWarnings, updatedList);
  }

  @override
  Future<List<EarlyWarning>> getUnreadWarnings() async {
    final warnings = await getWarnings();
    return warnings.where((w) => !w.isRead).toList();
  }
}
