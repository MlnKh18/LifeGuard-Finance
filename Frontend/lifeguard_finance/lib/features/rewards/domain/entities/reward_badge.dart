import 'package:equatable/equatable.dart';

class RewardBadge extends Equatable {
  final String name;
  final int thresholdPoints;
  final String iconName;

  const RewardBadge({
    required this.name,
    required this.thresholdPoints,
    required this.iconName,
  });

  @override
  List<Object?> get props => [name, thresholdPoints, iconName];
}

const RewardBadge starterSaverBadge = RewardBadge(name: 'Starter Saver', thresholdPoints: 0, iconName: 'savings');
const RewardBadge emergencyBuilderBadge = RewardBadge(name: 'Emergency Builder', thresholdPoints: 50, iconName: 'shield');
const RewardBadge helpfulFamilyBadge = RewardBadge(name: 'Helpful Family', thresholdPoints: 100, iconName: 'volunteer_activism');
const RewardBadge financialGuardianBadge = RewardBadge(name: 'Financial Guardian', thresholdPoints: 200, iconName: 'military_tech');

const List<RewardBadge> rewardBadges = [
  starterSaverBadge,
  emergencyBuilderBadge,
  helpfulFamilyBadge,
  financialGuardianBadge,
];
