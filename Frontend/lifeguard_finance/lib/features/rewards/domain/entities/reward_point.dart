import 'package:equatable/equatable.dart';

enum RewardActivityType { readLiteracy, completeVault, createCommunityPost, createCommunityComment, helpfulComment }

class RewardPoint extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final RewardActivityType activityType;
  final String sourceId;
  final int points;
  final String description;
  final DateTime createdAt;

  const RewardPoint({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.activityType,
    required this.sourceId,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  static RewardActivityType parseActivityType(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    switch (raw) {
      case 'readliteracy':
      case 'literacymodule':
        return RewardActivityType.readLiteracy;
      case 'completevault':
      case 'vaultcompleted':
        return RewardActivityType.completeVault;
      case 'createcommunitypost':
      case 'post':
        return RewardActivityType.createCommunityPost;
      case 'createcommunitycomment':
      case 'comment':
        return RewardActivityType.createCommunityComment;
      case 'helpfulcomment':
        return RewardActivityType.helpfulComment;
      default:
        return RewardActivityType.createCommunityPost;
    }
  }

  factory RewardPoint.fromJson(Map<String, dynamic> json) {
    return RewardPoint(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      activityType: parseActivityType(json['activityType'] ?? json['source']),
      sourceId: json['sourceId'] as String? ?? '',
      points: json['points'] as int,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'activityType': activityType.name,
      'sourceId': sourceId,
      'points': points,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, userEmail, userName, activityType, sourceId, points, description, createdAt];
}

String rewardActivityTypeLabel(RewardActivityType type) {
  switch (type) {
    case RewardActivityType.readLiteracy:
      return 'Membaca Modul Edukasi';
    case RewardActivityType.completeVault:
      return 'Menyelesaikan Target Tabungan';
    case RewardActivityType.createCommunityPost:
      return 'Membuat Post Community';
    case RewardActivityType.createCommunityComment:
      return 'Membuat Komentar Community';
    case RewardActivityType.helpfulComment:
      return 'Komentar Bermanfaat';
  }
}
