import '../entities/community_post.dart';
import '../entities/community_comment.dart';
import '../entities/community_report.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> getPosts();
  Future<CommunityPost?> getPostById(String postId);
  Future<void> createPost(CommunityPost post);
  Future<void> updatePost(CommunityPost post);
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);

  Future<List<CommunityComment>> getCommentsByPostId(String postId);
  Future<void> createComment(CommunityComment comment);
  Future<void> likeComment(String commentId);
  Future<void> unlikeComment(String commentId);
  Future<void> markCommentHelpful(String commentId);

  Future<void> reportPost({
    required String postId,
    required CommunityReportReason reason,
    required String description,
  });
}
