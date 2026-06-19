import 'package:equatable/equatable.dart';

class RewardBadge extends Equatable {
  final String badgeId;
  final String badgeName;
  final String description;
  final int minPoints;
  final String iconKey;

  const RewardBadge({
    required this.badgeId,
    required this.badgeName,
    required this.description,
    required this.minPoints,
    required this.iconKey,
  });

  @override
  List<Object?> get props => [badgeId, badgeName, description, minPoints, iconKey];
}

const RewardBadge starterLearnerBadge = RewardBadge(
  badgeId: 'starter_learner',
  badgeName: 'Starter Learner',
  description: 'Mulai membangun kebiasaan finansial sehat.',
  minPoints: 0,
  iconKey: 'star_outline',
);

const RewardBadge smartSaverBadge = RewardBadge(
  badgeId: 'smart_saver',
  badgeName: 'Smart Saver',
  description: 'Aktif menabung dan memantau target keuangan.',
  minPoints: 25,
  iconKey: 'savings',
);

const RewardBadge financialBuilderBadge = RewardBadge(
  badgeId: 'financial_builder',
  badgeName: 'Financial Builder',
  description: 'Konsisten belajar dan menjalankan aksi keuangan.',
  minPoints: 75,
  iconKey: 'trending_up',
);

const RewardBadge familyGuardianBadge = RewardBadge(
  badgeId: 'family_guardian',
  badgeName: 'Family Guardian',
  description: 'Berperan aktif menjaga ketahanan finansial keluarga.',
  minPoints: 150,
  iconKey: 'shield',
);

const RewardBadge financialChampionBadge = RewardBadge(
  badgeId: 'financial_champion',
  badgeName: 'Financial Champion',
  description: 'Menjadi teladan dalam pengelolaan keuangan keluarga.',
  minPoints: 300,
  iconKey: 'military_tech',
);

const List<RewardBadge> rewardBadges = [
  starterLearnerBadge,
  smartSaverBadge,
  financialBuilderBadge,
  familyGuardianBadge,
  financialChampionBadge,
];
