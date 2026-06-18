import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/community_challenge.dart';
import '../../domain/entities/community_feed.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_progress.dart';
import '../../domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final HiveService hiveService;

  CommunityRepositoryImpl({required this.hiveService});

  @override
  Future<CommunityFeed?> getFeed() async {
    final raw = hiveService.getData(LocalKeys.communityPosts);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw as Map);
    return CommunityFeed(
      progress: CommunityProgress.fromJson(Map<String, dynamic>.from(map['progress'] as Map)),
      posts: (map['posts'] as List)
          .map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      challenges: (map['challenges'] as List)
          .map((e) => CommunityChallenge.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  @override
  Future<void> saveFeed(CommunityFeed feed) async {
    await hiveService.saveData(LocalKeys.communityPosts, {
      'progress': feed.progress.toJson(),
      'posts': feed.posts.map((p) => p.toJson()).toList(),
      'challenges': feed.challenges.map((c) => c.toJson()).toList(),
    });
  }
}
