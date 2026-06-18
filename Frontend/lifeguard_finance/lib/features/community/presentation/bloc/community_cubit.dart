import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/community_challenge.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_progress.dart';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final HiveService hiveService;

  CommunityCubit({required this.hiveService}) : super(CommunityLoading());

  Future<void> loadFeed() async {
    emit(CommunityLoading());
    try {
      final raw = hiveService.getData(LocalKeys.communityPosts);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        emit(CommunityLoaded(
          progress: CommunityProgress.fromJson(Map<String, dynamic>.from(map['progress'] as Map)),
          posts: (map['posts'] as List)
              .map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
          challenges: (map['challenges'] as List)
              .map((e) => CommunityChallenge.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
        ));
      } else {
        final seed = _seedState();
        emit(seed);
        await _persist(seed);
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

  Future<void> addPost({required String content, required String tag}) async {
    final current = state;
    if (current is! CommunityLoaded) return;

    final newPost = CommunityPost(
      id: const Uuid().v4(),
      authorName: 'Anda (Anonim)',
      tag: tag,
      content: content,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
    );
    final updated = current.copyWith(posts: [newPost, ...current.posts]);
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
    await hiveService.saveData(LocalKeys.communityPosts, {
      'progress': state.progress.toJson(),
      'posts': state.posts.map((p) => p.toJson()).toList(),
      'challenges': state.challenges.map((c) => c.toJson()).toList(),
    });
  }

  CommunityLoaded _seedState() {
    final now = DateTime.now();
    return CommunityLoaded(
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
          tag: '#SandwichGeneration',
          content:
              'Bagaimana cara kalian mengatur porsi pendapatan untuk orang tua dan juga menabung untuk DP rumah secara bersamaan? Rasanya sulit sekali.',
          likeCount: 24,
          commentCount: 12,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        CommunityPost(
          id: const Uuid().v4(),
          authorName: 'Reza K.',
          tag: '#EmergencyFund',
          content:
              'Baru saja menggunakan dana darurat untuk biaya medis dadakan. Sedikit panik karena saldonya menipis, adakah tips untuk membangunnya kembali dengan cepat?',
          likeCount: 45,
          commentCount: 28,
          isFlagged: true,
          createdAt: now.subtract(const Duration(hours: 5)),
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
