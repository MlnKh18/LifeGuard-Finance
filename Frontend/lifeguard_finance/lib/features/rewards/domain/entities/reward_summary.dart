import 'package:equatable/equatable.dart';
import 'reward_badge.dart';
import 'reward_point.dart';

class RewardSummary extends Equatable {
  final int totalPoints;
  final RewardBadge? activeBadge;
  final RewardBadge? nextBadge;
  final int pointsToNextBadge;
  final List<RewardPoint> transactions;
  final List<RewardPoint> latestTransactions;
  final List<RewardBadge> badges;

  const RewardSummary({
    required this.totalPoints,
    required this.activeBadge,
    required this.nextBadge,
    required this.pointsToNextBadge,
    required this.transactions,
    required this.latestTransactions,
    required this.badges,
  });

  @override
  List<Object?> get props => [
        totalPoints,
        activeBadge,
        nextBadge,
        pointsToNextBadge,
        transactions,
        latestTransactions,
        badges,
      ];
}
