import 'package:equatable/equatable.dart';

class CommunityChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final int progressCurrent;
  final int progressTotal;
  final int xpReward;
  final bool isPrimary;

  const CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.progressCurrent,
    required this.progressTotal,
    required this.xpReward,
    required this.isPrimary,
  });

  double get progress => progressTotal <= 0 ? 0.0 : (progressCurrent / progressTotal).clamp(0.0, 1.0);

  bool get isCompleted => progressCurrent >= progressTotal;

  CommunityChallenge copyWith({int? progressCurrent}) {
    return CommunityChallenge(
      id: id,
      title: title,
      description: description,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal,
      xpReward: xpReward,
      isPrimary: isPrimary,
    );
  }

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    return CommunityChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      progressCurrent: json['progressCurrent'] as int,
      progressTotal: json['progressTotal'] as int,
      xpReward: json['xpReward'] as int,
      isPrimary: json['isPrimary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progressCurrent': progressCurrent,
      'progressTotal': progressTotal,
      'xpReward': xpReward,
      'isPrimary': isPrimary,
    };
  }

  @override
  List<Object?> get props => [id, title, description, progressCurrent, progressTotal, xpReward, isPrimary];
}
