import 'community_challenge.dart';
import 'community_post.dart';
import 'community_progress.dart';

class CommunityFeed {
  final CommunityProgress progress;
  final List<CommunityPost> posts;
  final List<CommunityChallenge> challenges;

  const CommunityFeed({
    required this.progress,
    required this.posts,
    required this.challenges,
  });

  CommunityFeed copyWith({
    CommunityProgress? progress,
    List<CommunityPost>? posts,
    List<CommunityChallenge>? challenges,
  }) {
    return CommunityFeed(
      progress: progress ?? this.progress,
      posts: posts ?? this.posts,
      challenges: challenges ?? this.challenges,
    );
  }
}
