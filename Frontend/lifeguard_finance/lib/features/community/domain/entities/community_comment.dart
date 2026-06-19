import 'package:equatable/equatable.dart';

class CommunityComment extends Equatable {
  final String id;
  final String postId;
  final String authorName;
  final String content;
  final bool isHelpful;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isHelpful = false,
  });

  CommunityComment copyWith({bool? isHelpful}) {
    return CommunityComment(
      id: id,
      postId: postId,
      authorName: authorName,
      content: content,
      createdAt: createdAt,
      isHelpful: isHelpful ?? this.isHelpful,
    );
  }

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isHelpful: json['isHelpful'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isHelpful': isHelpful,
    };
  }

  @override
  List<Object?> get props => [id, postId, authorName, content, isHelpful, createdAt];
}
