import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../rewards/data/datasources/reward_service.dart';
import '../../../rewards/domain/entities/reward_point.dart';
import '../../domain/entities/community_comment.dart';
import '../../domain/entities/community_feed.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_progress.dart';
import '../../domain/entities/community_challenge.dart';
import '../../domain/repositories/community_repository.dart';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository communityRepository;
  final RewardService rewardService;

  CommunityCubit({required this.communityRepository, required this.rewardService}) : super(CommunityLoading());

  Future<void> loadFeed() async {
    emit(CommunityLoading());
    try {
      final existing = await communityRepository.getFeed();
      if (existing != null) {
        emit(CommunityLoaded(progress: existing.progress, posts: existing.posts, challenges: existing.challenges));
      } else {
        final seed = _seedFeed();
        emit(CommunityLoaded(progress: seed.progress, posts: seed.posts, challenges: seed.challenges));
        await communityRepository.saveFeed(seed);
      }
    } catch (e) {
      emit(CommunityError('Gagal memuat data komunitas: $e'));
    }
  }

  Future<void> toggleLike(String postId) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final updatedPosts = current.posts.map((post) {
      if (post.id != postId) return post;
      final liked = !post.isLiked;
      return post.copyWith(isLiked: liked, likeCount: post.likeCount + (liked ? 1 : -1));
    }).toList();

    final updated = current.copyWith(posts: updatedPosts);
    emit(updated);
    await _persist(updated);
  }

  Future<void> addPost({required String content, required String category}) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final newPost = CommunityPost(
      id: const Uuid().v4(),
      authorName: 'Anda (Anonim)',
      category: category,
      content: content,
      likeCount: 0,
      createdAt: DateTime.now(),
    );
    final updated = current.copyWith(posts: [newPost, ...current.posts]);
    emit(updated);
    await _persist(updated);
    await rewardService.addPoints(RewardSource.post, 10);
  }

  Future<void> addComment(String postId, {required String content}) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final comment = CommunityComment(
      id: const Uuid().v4(),
      postId: postId,
      authorName: 'Anda (Anonim)',
      content: content,
      createdAt: DateTime.now(),
    );
    final updatedPosts = current.posts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(comments: [...post.comments, comment]);
    }).toList();

    final updated = current.copyWith(posts: updatedPosts);
    emit(updated);
    await _persist(updated);
    await rewardService.addPoints(RewardSource.comment, 5);
  }

  Future<void> markCommentHelpful(String postId, String commentId) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final post = current.posts.firstWhere((p) => p.id == postId);
    final comment = post.comments.firstWhere((c) => c.id == commentId);
    if (comment.isHelpful) return;

    final updatedPosts = current.posts.map((p) {
      if (p.id != postId) return p;
      final updatedComments = p.comments.map((c) => c.id == commentId ? c.copyWith(isHelpful: true) : c).toList();
      return p.copyWith(comments: updatedComments);
    }).toList();

    final updated = current.copyWith(posts: updatedPosts);
    emit(updated);
    await _persist(updated);
    await rewardService.addPoints(RewardSource.helpfulComment, 20);
  }

  Future<void> reportPost(String postId) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final updatedPosts = current.posts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(status: PostStatus.flagged);
    }).toList();

    final updated = current.copyWith(posts: updatedPosts);
    emit(updated);
    await _persist(updated);
  }

  Future<void> progressChallenge(String challengeId) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final challenge = current.challenges.firstWhere((c) => c.id == challengeId);
    if (challenge.isCompleted) return;

    final updatedChallenges = current.challenges
        .map((c) => c.id == challengeId ? c.copyWith(progressCurrent: c.progressCurrent + 1) : c)
        .toList();
    final justCompleted = updatedChallenges.firstWhere((c) => c.id == challengeId).isCompleted;

    final updatedProgress = justCompleted
        ? current.progress.copyWith(xp: current.progress.xp + challenge.xpReward)
        : current.progress;

    final updated = current.copyWith(challenges: updatedChallenges, progress: updatedProgress);
    emit(updated);
    await _persist(updated);
  }

  Future<void> _persist(CommunityLoaded state) async {
    await communityRepository.saveFeed(CommunityFeed(progress: state.progress, posts: state.posts, challenges: state.challenges));
  }

  CommunityFeed _seedFeed() {
    final now = DateTime.now();
    final rezaPostId = const Uuid().v4();
    return CommunityFeed(
      progress: const CommunityProgress(
        xp: 135,
        badge: 'Financial Guardian',
        weeklyGoalCurrent: 4,
        weeklyGoalTotal: 5,
      ),
      posts: [
        CommunityPost(
          id: const Uuid().v4(),
          authorName: 'Sarah L.',
          category: 'Generasi Sandwich',
          content:
              'Bagaimana cara kalian mengatur porsi pendapatan untuk orang tua dan juga menabung untuk DP rumah secara bersamaan? Rasanya sulit sekali.',
          likeCount: 24,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        CommunityPost(
          id: rezaPostId,
          authorName: 'Reza K.',
          category: 'Dana Darurat',
          content:
              'Baru saja menggunakan dana darurat untuk biaya medis dadakan. Sedikit panik karena saldonya menipis, adakah tips untuk membangunnya kembali dengan cepat?',
          likeCount: 45,
          createdAt: now.subtract(const Duration(hours: 5)),
          comments: [
            CommunityComment(
              id: const Uuid().v4(),
              postId: rezaPostId,
              authorName: 'Dimas P.',
              content: 'Coba sisihkan otomatis 10% dari setiap pendapatan masuk ke vault dana darurat.',
              createdAt: now.subtract(const Duration(hours: 4)),
            ),
          ],
        ),
      ],
      challenges: const [
        CommunityChallenge(
          id: 'weekly-expense-log',
          title: 'Fokus Minggu Ini',
          description: 'Catat setiap pengeluaran selama 7 hari berturut-turut.',
          progressCurrent: 4,
          progressTotal: 7,
          xpReward: 50,
          isPrimary: true,
        ),
        CommunityChallenge(
          id: 'read-one-article',
          title: 'Baca 1 Artikel',
          description: '+10 XP',
          progressCurrent: 0,
          progressTotal: 1,
          xpReward: 10,
          isPrimary: false,
        ),
      ],
    );
  }
}
