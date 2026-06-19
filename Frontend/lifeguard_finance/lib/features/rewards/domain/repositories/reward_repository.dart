import '../entities/reward_badge.dart';
import '../entities/reward_point.dart';
import '../entities/reward_summary.dart';

abstract class RewardRepository {
  Future<List<RewardPoint>> getTransactions();
  Future<List<RewardPoint>> getTransactionsByCurrentUser();
  Future<int> getTotalPoints();
  Future<List<RewardBadge>> getBadges();
  Future<RewardBadge?> getActiveBadge();
  Future<RewardBadge?> getNextBadge();
  Future<RewardSummary> getRewardSummary();
  Future<void> grantRewardIfNotExists({
    required String userId,
    required String userEmail,
    required String userName,
    required RewardActivityType activityType,
    required String sourceId,
    required int points,
    required String description,
  });
  Future<bool> hasReward({
    required String userId,
    required RewardActivityType activityType,
    required String sourceId,
  });
}
