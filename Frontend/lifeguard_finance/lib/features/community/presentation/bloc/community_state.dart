import 'package:equatable/equatable.dart';
import '../../domain/entities/community_challenge.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_progress.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final CommunityProgress progress;
  final List<CommunityPost> posts;
  final List<CommunityChallenge> challenges;

  const CommunityLoaded({
    required this.progress,
    required this.posts,
    required this.challenges,
  });

  CommunityLoaded copyWith({
    CommunityProgress? progress,
    List<CommunityPost>? posts,
    List<CommunityChallenge>? challenges,
  }) {
    return CommunityLoaded(
      progress: progress ?? this.progress,
      posts: posts ?? this.posts,
      challenges: challenges ?? this.challenges,
    );
  }

  @override
  List<Object?> get props => [progress, posts, challenges];
}

class CommunityError extends CommunityState {
  final String message;

  const CommunityError(this.message);

  @override
  List<Object?> get props => [message];
}
