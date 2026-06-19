import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../rewards/domain/repositories/reward_repository.dart';
import '../../../rewards/domain/entities/reward_point.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/community_comment.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_report.dart';
import '../../domain/repositories/community_repository.dart';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository communityRepository;
  final RewardRepository rewardRepository;
  final AuthRepository authRepository;

  CommunityCubit({
    required this.communityRepository,
    required this.rewardRepository,
    required this.authRepository,
  }) : super(CommunityInitial());

  Future<void> loadPosts({String topic = 'Semua'}) async {
    emit(CommunityLoading());
    try {
      final posts = await communityRepository.getPosts();
      final filtered = topic == 'Semua' ? posts : posts.where((p) => p.topic == topic).toList();
      emit(CommunityLoaded(posts: filtered, selectedTopic: topic));
    } catch (e) {
      if (e.toString().contains('Akses ditolak')) {
        emit(CommunityAccessDenied());
      } else {
        emit(CommunityError(e.toString()));
      }
    }
  }

  Future<void> loadPostDetail(String postId) async {
    emit(CommunityLoading());
    try {
      final post = await communityRepository.getPostById(postId);
      if (post == null) {
        emit(const CommunityError('Post tidak ditemukan.'));
        return;
      }
      final comments = await communityRepository.getCommentsByPostId(postId);
      emit(CommunityPostDetailLoaded(post: post, comments: comments));
    } catch (e) {
      if (e.toString().contains('Akses ditolak')) {
        emit(CommunityAccessDenied());
      } else {
        emit(CommunityError(e.toString()));
      }
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String topic,
  }) async {
    final currentState = state;
    String currentTopic = 'Semua';
    if (currentState is CommunityLoaded) {
      currentTopic = currentState.selectedTopic;
    }
    
    emit(CommunityActionLoading());
    try {
      final newPost = CommunityPost(
        postId: const Uuid().v4(),
        familyId: '',
        authorUserId: '',
        authorName: '',
        authorEmail: '',
        title: title,
        content: content,
        topic: topic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await communityRepository.createPost(newPost);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        await rewardRepository.grantRewardIfNotExists(
          userId: user.userId,
          userEmail: user.email,
          userName: user.fullName,
          activityType: RewardActivityType.createCommunityPost,
          sourceId: newPost.postId,
          points: 10,
          description: 'Membuat post community.',
        );
      }
      
      emit(const CommunityActionSuccess('Post berhasil dipublikasikan.'));
      await loadPosts(topic: currentTopic);
    } catch (e) {
      emit(CommunityError(e.toString()));
      await loadPosts(topic: currentTopic);
    }
  }

  Future<void> likePost(String postId) async {
    final currentState = state;
    try {
      await communityRepository.likePost(postId);
      if (currentState is CommunityLoaded) {
        await loadPosts(topic: currentState.selectedTopic);
      } else if (currentState is CommunityPostDetailLoaded) {
        await loadPostDetail(postId);
      }
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> unlikePost(String postId) async {
    final currentState = state;
    try {
      await communityRepository.unlikePost(postId);
      if (currentState is CommunityLoaded) {
        await loadPosts(topic: currentState.selectedTopic);
      } else if (currentState is CommunityPostDetailLoaded) {
        await loadPostDetail(postId);
      }
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> createComment(String postId, {required String content}) async {
    emit(CommunityActionLoading());
    try {
      final comment = CommunityComment(
        commentId: const Uuid().v4(),
        postId: postId,
        familyId: '',
        authorUserId: '',
        authorName: '',
        authorEmail: '',
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await communityRepository.createComment(comment);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        await rewardRepository.grantRewardIfNotExists(
          userId: user.userId,
          userEmail: user.email,
          userName: user.fullName,
          activityType: RewardActivityType.createCommunityComment,
          sourceId: comment.commentId,
          points: 5,
          description: 'Membuat komentar community.',
        );
      }
      
      emit(const CommunityActionSuccess('Komentar berhasil ditambahkan.'));
      await loadPostDetail(postId);
    } catch (e) {
      emit(CommunityError(e.toString()));
      await loadPostDetail(postId);
    }
  }

  Future<void> likeComment(String postId, String commentId) async {
    try {
      await communityRepository.likeComment(commentId);
      await loadPostDetail(postId);
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> unlikeComment(String postId, String commentId) async {
    try {
      await communityRepository.unlikeComment(commentId);
      await loadPostDetail(postId);
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> markCommentHelpful(String postId, String commentId) async {
    try {
      await communityRepository.markCommentHelpful(commentId);
      final comments = await communityRepository.getCommentsByPostId(postId);
      final comment = comments.where((c) => c.commentId == commentId).firstOrNull;
      
      if (comment != null && comment.authorUserId.isNotEmpty) {
        await rewardRepository.grantRewardIfNotExists(
          userId: comment.authorUserId,
          userEmail: comment.authorEmail,
          userName: comment.authorName,
          activityType: RewardActivityType.helpfulComment,
          sourceId: commentId,
          points: 20,
          description: 'Komentar ditandai bermanfaat.',
        );
      }
      await loadPostDetail(postId);
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> reportPost(String postId, CommunityReportReason reason, String description) async {
    emit(CommunityActionLoading());
    try {
      await communityRepository.reportPost(
        postId: postId,
        reason: reason,
        description: description,
      );
      emit(const CommunityActionSuccess('Laporan berhasil dikirim.'));
      await loadPosts();
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }
}
