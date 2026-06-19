import 'package:equatable/equatable.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_comment.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {}
class CommunityLoading extends CommunityState {}
class CommunityActionLoading extends CommunityState {}

class CommunityActionSuccess extends CommunityState {
  final String message;
  const CommunityActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CommunityLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final String selectedTopic;

  const CommunityLoaded({
    required this.posts,
    this.selectedTopic = 'Semua',
  });

  CommunityLoaded copyWith({
    List<CommunityPost>? posts,
    String? selectedTopic,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      selectedTopic: selectedTopic ?? this.selectedTopic,
    );
  }

  @override
  List<Object?> get props => [posts, selectedTopic];
}

class CommunityPostDetailLoaded extends CommunityState {
  final CommunityPost post;
  final List<CommunityComment> comments;

  const CommunityPostDetailLoaded({
    required this.post,
    required this.comments,
  });

  CommunityPostDetailLoaded copyWith({
    CommunityPost? post,
    List<CommunityComment>? comments,
  }) {
    return CommunityPostDetailLoaded(
      post: post ?? this.post,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [post, comments];
}

class CommunityError extends CommunityState {
  final String message;

  const CommunityError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommunityAccessDenied extends CommunityState {}
