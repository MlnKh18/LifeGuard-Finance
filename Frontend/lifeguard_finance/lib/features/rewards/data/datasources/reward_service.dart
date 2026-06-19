import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/reward_badge.dart';
import '../../domain/entities/reward_point.dart';

class RewardService {
  final HiveService hiveService;

  RewardService({required this.hiveService});

  Future<List<RewardPoint>> getLedger() async {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.rewardPoints);
    final list = (raw?['ledger'] as List<dynamic>?) ?? [];
    return list.map((e) => RewardPoint.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  int totalPoints(List<RewardPoint> ledger) => ledger.fold(0, (sum, e) => sum + e.points);

  RewardBadge badgeForPoints(int points) {
    var current = rewardBadges.first;
    for (final badge in rewardBadges) {
      if (points >= badge.thresholdPoints) current = badge;
    }
    return current;
  }

  Future<List<RewardPoint>> addPoints(RewardSource source, int points) async {
    final ledger = await getLedger();
    final entry = RewardPoint(id: const Uuid().v4(), source: source, points: points, createdAt: DateTime.now());
    final updated = [...ledger, entry];
    await hiveService.saveData(LocalKeys.rewardPoints, {
      'ledger': updated.map((e) => e.toJson()).toList(),
    });
    return updated;
  }
}
