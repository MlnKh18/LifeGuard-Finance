import 'package:equatable/equatable.dart';

enum RewardSource { post, comment, helpfulComment, literacyModule, vaultCompleted }

class RewardPoint extends Equatable {
  final String id;
  final RewardSource source;
  final int points;
  final DateTime createdAt;

  const RewardPoint({
    required this.id,
    required this.source,
    required this.points,
    required this.createdAt,
  });

  static RewardSource parseSource(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    switch (raw) {
      case 'comment':
        return RewardSource.comment;
      case 'helpfulcomment':
        return RewardSource.helpfulComment;
      case 'literacymodule':
        return RewardSource.literacyModule;
      case 'vaultcompleted':
        return RewardSource.vaultCompleted;
      default:
        return RewardSource.post;
    }
  }

  factory RewardPoint.fromJson(Map<String, dynamic> json) {
    return RewardPoint(
      id: json['id'] as String,
      source: parseSource(json['source']),
      points: json['points'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source.name,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, source, points, createdAt];
}
