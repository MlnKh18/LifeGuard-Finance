import 'package:equatable/equatable.dart';

enum CommunityPostStatus { published, flagged, removed }

const List<String> communityCategories = [
  'Utang dan Cicilan',
  'Dana Darurat',
  'Biaya Pendidikan',
  'Biaya Kesehatan',
  'Inflasi',
  'Generasi Sandwich',
  'Lainnya',
];

class CommunityPost extends Equatable {
  final String postId;
  final String familyId;
  final String authorUserId;
  final String authorName;
  final String authorEmail;
  final String title;
  final String content;
  final String topic;
  final CommunityPostStatus status;
  final int likeCount;
  final int commentCount;
  final int reportCount;
  final List<String> likedByUserIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityPost({
    required this.postId,
    required this.familyId,
    required this.authorUserId,
    required this.authorName,
    required this.authorEmail,
    required this.title,
    required this.content,
    required this.topic,
    required this.createdAt,
    required this.updatedAt,
    this.status = CommunityPostStatus.published,
    this.likeCount = 0,
    this.commentCount = 0,
    this.reportCount = 0,
    this.likedByUserIds = const [],
  });

  CommunityPost copyWith({
    String? familyId,
    String? authorUserId,
    String? authorName,
    String? authorEmail,
    String? title,
    String? content,
    String? topic,
    CommunityPostStatus? status,
    int? likeCount,
    int? commentCount,
    int? reportCount,
    List<String>? likedByUserIds,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      postId: postId,
      familyId: familyId ?? this.familyId,
      authorUserId: authorUserId ?? this.authorUserId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      title: title ?? this.title,
      content: content ?? this.content,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      reportCount: reportCount ?? this.reportCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static CommunityPostStatus parseStatus(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == 'flagged') return CommunityPostStatus.flagged;
    if (raw == 'removed') return CommunityPostStatus.removed;
    return CommunityPostStatus.published;
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      postId: json['postId'] as String? ?? json['id'] as String,
      familyId: json['familyId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      authorName: json['authorName'] as String,
      authorEmail: json['authorEmail'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String,
      topic: json['topic'] as String? ?? json['category'] as String? ?? communityCategories.first,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? (json['comments'] as List?)?.length ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      likedByUserIds: (json['likedByUserIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.parse(json['createdAt'] as String),
      status: parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'familyId': familyId,
      'authorUserId': authorUserId,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'title': title,
      'content': content,
      'topic': topic,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'reportCount': reportCount,
      'likedByUserIds': likedByUserIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }

  @override
  List<Object?> get props => [
        postId,
        familyId,
        authorUserId,
        authorName,
        authorEmail,
        title,
        content,
        topic,
        status,
        likeCount,
        commentCount,
        reportCount,
        likedByUserIds,
        createdAt,
        updatedAt,
      ];
}
