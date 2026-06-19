import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/literacy_module.dart';
import '../../domain/entities/literacy_summary.dart';
import '../../domain/entities/user_literacy_progress.dart';
import '../../domain/repositories/literacy_repository.dart';
import '../mock_literacy_data.dart';

import '../../../../core/network/api_client.dart';

class LiteracyRepositoryImpl implements LiteracyRepository {
  final HiveService hiveService;
  final ApiClient apiClient;
  final Uuid _uuid = const Uuid();

  LiteracyRepositoryImpl({
    required this.hiveService,
    required this.apiClient,
  });

  String get _currentUserId {
    final session = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.authSession);
    return session?['userId'] ?? 'unknown_user';
  }

  String? get _currentUserEmail {
    final session = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.authSession);
    return session?['email'];
  }

  @override
  Future<List<LiteracyModule>> getModules() async {
    final modules = seedLiteracyModules;
    debugPrint('================ LITERACY GET MODULES ================');
    debugPrint('modules count: ${modules.length}');
    for (final module in modules) {
      debugPrint(
        'MODULE => id=${module.moduleId}, title=${module.title}, indicator=${module.relatedIndicator}, source=${module.sourceName}, url=${module.externalUrl}',
      );
    }
    return modules;
  }

  @override
  Future<LiteracyModule?> getModuleById(String moduleId) async {
    final modules = await getModules();
    try {
      return modules.firstWhere((m) => m.moduleId == moduleId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<UserLiteracyProgress>> getUserProgress() async {
    final userId = _currentUserId;
    final progressMap = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.literacyProgress) ?? {};
    final userProgressList = progressMap[userId] as List<dynamic>? ?? [];

    // Sync with API in background
    apiClient.dio.get('/literacy/progress').catchError((e) => debugPrint('Sync error'));

    return userProgressList.map((e) {
      final map = e as Map<dynamic, dynamic>;
      return UserLiteracyProgress(
        progressId: map['progressId'] as String,
        userId: map['userId'] as String,
        userEmail: map['userEmail'] as String?,
        moduleId: map['moduleId'] as String,
        isRead: map['isRead'] as bool? ?? false,
        readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
        progressPercentage: (map['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  @override
  Future<void> markModuleAsRead(String moduleId) async {
    final userId = _currentUserId;
    final userEmail = _currentUserEmail;
    
    debugPrint('================ MARK LITERACY AS READ ================');
    debugPrint('userId: $userId');
    debugPrint('userEmail: $userEmail');
    debugPrint('moduleId: $moduleId');

    final progressMap = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.literacyProgress) ?? {};
    final userProgressListRaw = progressMap[userId] as List<dynamic>? ?? [];
    
    final List<Map<String, dynamic>> userProgressList = userProgressListRaw.map((e) {
      return Map<String, dynamic>.from(e as Map<dynamic, dynamic>);
    }).toList();

    final existingIndex = userProgressList.indexWhere((p) => p['moduleId'] == moduleId);

    if (existingIndex >= 0) {
      userProgressList[existingIndex]['isRead'] = true;
      userProgressList[existingIndex]['readAt'] = DateTime.now().toIso8601String();
      userProgressList[existingIndex]['progressPercentage'] = 100.0;
      userProgressList[existingIndex]['updatedAt'] = DateTime.now().toIso8601String();
    } else {
      userProgressList.add({
        'progressId': _uuid.v4(),
        'userId': userId,
        'userEmail': userEmail,
        'moduleId': moduleId,
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
        'progressPercentage': 100.0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    progressMap[userId] = userProgressList;
    await hiveService.saveData(LocalKeys.literacyProgress, progressMap);

    // Sync to API
    try {
      await apiClient.dio.post('/literacy/progress', data: {
        'moduleId': moduleId,
      });
    } catch (e) {
      debugPrint('Literacy API Sync Error: $e');
    }
  }

  @override
  Future<LiteracyModule?> getRecommendedModule(List<String> weakestIndicators) async {
    final modules = await getModules();
    if (modules.isEmpty) return null;

    if (weakestIndicators.isNotEmpty) {
      final matched = modules.where((module) => weakestIndicators.contains(module.relatedIndicator));
      if (matched.isNotEmpty) {
        return matched.first;
      }
    }

    final defaultRecommended = modules.where((module) => module.isRecommended);
    if (defaultRecommended.isNotEmpty) {
      return defaultRecommended.first;
    }

    return modules.first;
  }

  @override
  Future<LiteracySummary> getLiteracySummary(List<String> weakestIndicators) async {
    final modules = await getModules();
    final userProgress = await getUserProgress();

    final readModulesCount = userProgress.where((p) => p.isRead).length;
    final totalModules = modules.length;
    final percentage = totalModules > 0 ? (readModulesCount / totalModules) * 100 : 0.0;

    final readModuleIds = userProgress.where((p) => p.isRead).map((p) => p.moduleId).toSet();
    final latestReadModules = modules.where((m) => readModuleIds.contains(m.moduleId)).toList();

    List<LiteracyModule> recommendedModules = [];
    if (weakestIndicators.isNotEmpty) {
      recommendedModules = modules.where((m) => weakestIndicators.contains(m.relatedIndicator)).toList();
    }
    
    if (recommendedModules.isEmpty) {
      recommendedModules = modules.where((m) => m.isRecommended).toList();
    }

    if (recommendedModules.isEmpty && modules.isNotEmpty) {
      recommendedModules = [modules.first];
    }

    final summary = LiteracySummary(
      totalModules: totalModules,
      readModules: readModulesCount,
      unreadModules: totalModules - readModulesCount,
      progressPercentage: percentage,
      recommendedModule: recommendedModules.isNotEmpty ? recommendedModules.first : null,
      latestReadModules: latestReadModules,
      recommendedModules: recommendedModules,
    );

    debugPrint('================ LITERACY PROGRESS ================');
    debugPrint('currentUserId: $_currentUserId');
    debugPrint('progress count: ${userProgress.length}');
    debugPrint('read count: $readModulesCount');
    debugPrint('total modules: $totalModules');
    debugPrint('progress percentage: $percentage');

    return summary;
  }
}
