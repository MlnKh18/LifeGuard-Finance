import '../entities/community_feed.dart';

abstract class CommunityRepository {
  Future<CommunityFeed?> getFeed();
  Future<void> saveFeed(CommunityFeed feed);
}
