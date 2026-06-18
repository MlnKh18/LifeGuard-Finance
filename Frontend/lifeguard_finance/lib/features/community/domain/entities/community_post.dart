import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  final String id;
  final String authorName;
  final String tag;
  final String content;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isFlagged;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.tag,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.isLiked = false,
    this.isFlagged = false,
  });

  CommunityPost copyWith({int? likeCount, bool? isLiked}) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      tag: tag,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      isFlagged: isFlagged,
    );
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      tag: json['tag'] as String,
      content: json['content'] as String,
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLiked: json['isLiked'] as bool? ?? false,
      isFlagged: json['isFlagged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'tag': tag,
      'content': content,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'isFlagged': isFlagged,
    };
  }

  @override
  List<Object?> get props => [id, authorName, tag, content, likeCount, commentCount, isLiked, isFlagged, createdAt];
}
