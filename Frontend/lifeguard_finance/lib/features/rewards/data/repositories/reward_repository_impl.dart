import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/reward_badge.dart';
import '../../domain/entities/reward_point.dart';
import '../../domain/entities/reward_summary.dart';
import '../../domain/repositories/reward_repository.dart';

import '../../../../core/network/api_client.dart';

class RewardRepositoryImpl implements RewardRepository {
  final HiveService hiveService;
  final AuthRepository authRepository;
  final ApiClient apiClient;

  RewardRepositoryImpl({
    required this.hiveService,
    required this.authRepository,
    required this.apiClient,
  });

  @override
  Future<List<RewardPoint>> getTransactions() async {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.rewardPoints);
    final list = (raw?['ledger'] as List<dynamic>?) ?? [];
    return list.map((e) => RewardPoint.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<List<RewardPoint>> getTransactionsByCurrentUser() async {
    final session = authRepository.getCachedSession();
    if (session == null) return [];
    
    // Sync with API in background
    apiClient.dio.get('/rewards/history').catchError((e) => debugPrint('Sync error'));

    final all = await getTransactions();
    return all.where((t) => t.userId == session.currentUserId).toList();
  }

  @override
  Future<int> getTotalPoints() async {
    final txs = await getTransactionsByCurrentUser();
    return txs.fold<int>(0, (sum, e) => sum + e.points);
  }

  @override
  Future<List<RewardBadge>> getBadges() async {
    return rewardBadges;
  }

  @override
  Future<RewardBadge?> getActiveBadge() async {
    final points = await getTotalPoints();
    RewardBadge? current;
    for (final badge in rewardBadges) {
      if (points >= badge.minPoints) {
        if (current == null || badge.minPoints > current.minPoints) {
          current = badge;
        }
      }
    }
    return current ?? rewardBadges.first;
  }

  @override
  Future<RewardBadge?> getNextBadge() async {
    final points = await getTotalPoints();
    RewardBadge? next;
    for (final badge in rewardBadges) {
      if (badge.minPoints > points) {
        if (next == null || badge.minPoints < next.minPoints) {
          next = badge;
        }
      }
    }
    return next;
  }

  @override
  Future<RewardSummary> getRewardSummary() async {
    final points = await getTotalPoints();
    final active = await getActiveBadge();
    final next = await getNextBadge();
    final txs = await getTransactionsByCurrentUser();
    
    // Sort transactions by date descending
    txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest = txs.take(3).toList();
    
    final pointsToNext = next != null ? next.minPoints - points : 0;
    
    return RewardSummary(
      totalPoints: points,
      activeBadge: active,
      nextBadge: next,
      pointsToNextBadge: pointsToNext,
      transactions: txs,
      latestTransactions: latest,
      badges: rewardBadges,
    );
  }

  @override
  Future<bool> hasReward({
    required String userId,
    required RewardActivityType activityType,
    required String sourceId,
  }) async {
    final all = await getTransactions();
    return all.any((r) => r.userId == userId && r.activityType == activityType && r.sourceId == sourceId);
  }

  @override
  Future<void> grantRewardIfNotExists({
    required String userId,
    required String userEmail,
    required String userName,
    required RewardActivityType activityType,
    required String sourceId,
    required int points,
    required String description,
  }) async {
    debugPrint('================ GRANT REWARD ================');
    debugPrint('userId: $userId');
    debugPrint('userEmail: $userEmail');
    debugPrint('activityType: $activityType');
    debugPrint('sourceId: $sourceId');
    debugPrint('points: $points');

    final all = await getTransactions();
    final alreadyExists = all.any((r) => r.userId == userId && r.activityType == activityType && r.sourceId == sourceId);
    
    debugPrint('alreadyExists: $alreadyExists');
    
    if (alreadyExists) {
      debugPrint('Reward skipped. Already granted for sourceId=$sourceId');
      return;
    }

    final entry = RewardPoint(
      id: const Uuid().v4(),
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      activityType: activityType,
      sourceId: sourceId,
      points: points,
      description: description,
      createdAt: DateTime.now(),
    );

    final updated = [...all, entry];
    await hiveService.saveData(LocalKeys.rewardPoints, {
      'ledger': updated.map((e) => e.toJson()).toList(),
    });
    debugPrint('Reward granted successfully.');
  }
}
