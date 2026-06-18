import 'package:equatable/equatable.dart';
import 'community_comment.dart';

enum PostStatus { published, flagged, removed }

const List<String> communityCategories = [
  'Utang dan Cicilan',
  'Dana Darurat',
  'Biaya Pendidikan',
  'Biaya Kesehatan',
  'Inflasi',
  'Generasi Sandwich',
];

class CommunityPost extends Equatable {
  final String id;
  final String authorName;
  final String category;
  final String content;
  final int likeCount;
  final bool isLiked;
  final PostStatus status;
  final DateTime createdAt;
  final List<CommunityComment> comments;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.category,
    required this.content,
    required this.likeCount,
    required this.createdAt,
    this.isLiked = false,
    this.status = PostStatus.published,
    this.comments = const [],
  });

  int get commentCount => comments.length;

  CommunityPost copyWith({
    int? likeCount,
    bool? isLiked,
    PostStatus? status,
    List<CommunityComment>? comments,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      category: category,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      status: status ?? this.status,
      comments: comments ?? this.comments,
    );
  }

  static PostStatus parseStatus(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == 'flagged') return PostStatus.flagged;
    if (raw == 'removed') return PostStatus.removed;
    return PostStatus.published;
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      category: json['category'] as String? ?? communityCategories.first,
      content: json['content'] as String,
      likeCount: json['likeCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLiked: json['isLiked'] as bool? ?? false,
      status: parseStatus(json['status']),
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommunityComment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'category': category,
      'content': content,
      'likeCount': likeCount,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'status': status.name,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, authorName, category, content, likeCount, isLiked, status, createdAt, comments];
}
