import 'package:equatable/equatable.dart';

class CommunityProgress extends Equatable {
  final int xp;
  final String badge;
  final int weeklyGoalCurrent;
  final int weeklyGoalTotal;

  const CommunityProgress({
    required this.xp,
    required this.badge,
    required this.weeklyGoalCurrent,
    required this.weeklyGoalTotal,
  });

  CommunityProgress copyWith({int? xp, int? weeklyGoalCurrent}) {
    return CommunityProgress(
      xp: xp ?? this.xp,
      badge: badge,
      weeklyGoalCurrent: weeklyGoalCurrent ?? this.weeklyGoalCurrent,
      weeklyGoalTotal: weeklyGoalTotal,
    );
  }

  factory CommunityProgress.fromJson(Map<String, dynamic> json) {
    return CommunityProgress(
      xp: json['xp'] as int,
      badge: json['badge'] as String,
      weeklyGoalCurrent: json['weeklyGoalCurrent'] as int,
      weeklyGoalTotal: json['weeklyGoalTotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'badge': badge,
      'weeklyGoalCurrent': weeklyGoalCurrent,
      'weeklyGoalTotal': weeklyGoalTotal,
    };
  }

  @override
  List<Object?> get props => [xp, badge, weeklyGoalCurrent, weeklyGoalTotal];
}
