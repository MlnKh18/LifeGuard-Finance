import 'package:equatable/equatable.dart';

class CommunityComment extends Equatable {
  final String commentId;
  final String postId;
  final String familyId;
  final String authorUserId;
  final String authorName;
  final String authorEmail;
  final String content;
  final int likeCount;
  final List<String> likedByUserIds;
  final bool isHelpful;
  final String? markedHelpfulByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityComment({
    required this.commentId,
    required this.postId,
    required this.familyId,
    required this.authorUserId,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.likedByUserIds = const [],
    this.isHelpful = false,
    this.markedHelpfulByUserId,
  });

  CommunityComment copyWith({
    String? familyId,
    String? authorUserId,
    String? authorName,
    String? authorEmail,
    String? content,
    int? likeCount,
    List<String>? likedByUserIds,
    bool? isHelpful,
    String? markedHelpfulByUserId,
    DateTime? updatedAt,
  }) {
    return CommunityComment(
      commentId: commentId,
      postId: postId,
      familyId: familyId ?? this.familyId,
      authorUserId: authorUserId ?? this.authorUserId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isHelpful: isHelpful ?? this.isHelpful,
      markedHelpfulByUserId: markedHelpfulByUserId ?? this.markedHelpfulByUserId,
    );
  }

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      commentId: json['commentId'] as String? ?? json['id'] as String,
      postId: json['postId'] as String,
      familyId: json['familyId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      authorName: json['authorName'] as String,
      authorEmail: json['authorEmail'] as String? ?? '',
      content: json['content'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      likedByUserIds: (json['likedByUserIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isHelpful: json['isHelpful'] as bool? ?? false,
      markedHelpfulByUserId: json['markedHelpfulByUserId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'familyId': familyId,
      'authorUserId': authorUserId,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'content': content,
      'likeCount': likeCount,
      'likedByUserIds': likedByUserIds,
      'isHelpful': isHelpful,
      'markedHelpfulByUserId': markedHelpfulByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        commentId,
        postId,
        familyId,
        authorUserId,
        authorName,
        authorEmail,
        content,
        likeCount,
        likedByUserIds,
        isHelpful,
        markedHelpfulByUserId,
        createdAt,
        updatedAt,
      ];
}
