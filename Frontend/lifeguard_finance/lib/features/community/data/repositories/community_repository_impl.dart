import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_comment.dart';
import '../../domain/entities/community_report.dart';
import '../../domain/repositories/community_repository.dart';

import '../../../../core/network/api_client.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final HiveService hiveService;
  final ApiClient apiClient;

  CommunityRepositoryImpl({
    required this.hiveService,
    required this.apiClient,
  });

  Future<void> _validateRoleAndGetAuth(Future<void> Function(String userId, String userEmail, String userName, String familyId) onValid) async {
    final authRepo = getIt<AuthRepository>();
    final session = await authRepo.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      throw Exception('Harap login terlebih dahulu.');
    }
    if (session.currentUserRole != UserRole.headOfFamily) {
      throw Exception('Akses ditolak. Fitur ini hanya untuk Kepala Keluarga.');
    }
    final user = await authRepo.getCurrentUser();
    await onValid(session.currentUserId, user?.email ?? '', user?.fullName ?? '', session.currentFamilyId);
  }

  @override
  Future<List<CommunityPost>> getPosts() async {
    String currentUserId = '';
    String currentEmail = '';
    String currentFamilyId = '';

    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
      currentEmail = email;
      currentFamilyId = familyId;
    });

    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.communityPosts);
    final rawPosts = (raw?['posts'] as List<dynamic>?) ?? [];
    
    // Sync with API properly and merge with local cache
    try {
      final response = await apiClient.dio.get('/community/posts');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        final apiPosts = data.map((json) {
           return CommunityPost(
             postId: json['id'] ?? const Uuid().v4(),
             familyId: json['familyId'] ?? '',
             authorUserId: json['authorId'] ?? '',
             authorEmail: '', // Backend doesn't return email, can be empty
             authorName: json['authorName'] ?? 'Anonim',
             title: json['title'] ?? '',
             content: json['content'] ?? '',
             topic: json['topic'] ?? 'Umum',
             likeCount: json['likeCount'] ?? 0,
             commentCount: json['commentCount'] ?? 0,
             reportCount: json['reportCount'] ?? 0,
             status: CommunityPostStatus.values.firstWhere(
               (e) => e.toString().split('.').last == json['status'],
               orElse: () => CommunityPostStatus.published,
             ),
             likedByUserIds: [],
             createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
             updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
           );
        }).toList();

        // Merge apiPosts with rawPosts based on postId, keeping local like/report logic if needed
        final Map<String, CommunityPost> mergedMap = {};
        for (var raw in rawPosts) {
          final p = CommunityPost.fromJson(Map<String, dynamic>.from(raw as Map));
          mergedMap[p.postId] = p;
        }
        for (var apiPost in apiPosts) {
          // Remove local dummy posts that match the same title and author but have different UUIDs
          final duplicateLocalId = mergedMap.keys.firstWhere(
            (id) => id != apiPost.postId && 
                    mergedMap[id]?.title == apiPost.title && 
                    mergedMap[id]?.authorUserId == apiPost.authorUserId,
            orElse: () => '',
          );
          
          if (duplicateLocalId.isNotEmpty) {
            // Inherit the likes from the local duplicate before removing it
            final localDuplicate = mergedMap[duplicateLocalId]!;
            apiPost = apiPost.copyWith(likedByUserIds: localDuplicate.likedByUserIds);
            mergedMap.remove(duplicateLocalId);
          }

          if (mergedMap.containsKey(apiPost.postId)) {
            // Keep local like count/arrays if they are not in API
            final local = mergedMap[apiPost.postId]!;
            mergedMap[apiPost.postId] = apiPost.copyWith(
              likedByUserIds: local.likedByUserIds,
            );
          } else {
            mergedMap[apiPost.postId] = apiPost;
          }
        }
        final mergedPosts = mergedMap.values.toList();
        
        // Sort by newest first
        mergedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        await _savePosts(mergedPosts);
        return mergedPosts;
      }
    } catch (e) {
      // debugPrint('Community API Get Error: $e');
    }

    final posts = rawPosts.map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    debugPrint('================ COMMUNITY GET POSTS ================');
    debugPrint('currentUserId: $currentUserId');
    debugPrint('currentEmail: $currentEmail');
    debugPrint('currentFamilyId: $currentFamilyId');
    debugPrint('raw post count: ${rawPosts.length}');
    debugPrint('mapped post count: ${posts.length}');

    return posts;
  }

  @override
  Future<CommunityPost?> getPostById(String postId) async {
    final posts = await getPosts();
    try {
      return posts.firstWhere((p) => p.postId == postId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createPost(CommunityPost post) async {
    String currentUserId = '';
    String currentEmail = '';
    String currentFamilyId = '';
    String authorName = post.authorName;

    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
      currentEmail = email;
      currentFamilyId = familyId;
      if (userName.isNotEmpty) {
        authorName = userName;
      }
    });

    final newPost = post.copyWith(
      familyId: currentFamilyId,
      authorUserId: currentUserId,
      authorEmail: currentEmail,
      authorName: authorName,
      updatedAt: DateTime.now(),
    );

    debugPrint('================ CREATE COMMUNITY POST ================');
    debugPrint('title: ${newPost.title}');
    debugPrint('topic: ${newPost.topic}');
    debugPrint('familyId: ${newPost.familyId}');
    debugPrint('authorUserId: ${newPost.authorUserId}');
    debugPrint('authorEmail: ${newPost.authorEmail}');

    CommunityPost finalPost = newPost;

    // Sync to Backend first to get the real UUID
    try {
      final response = await apiClient.dio.post('/community/posts', data: {
        'title': newPost.title,
        'content': newPost.content,
        'topic': newPost.topic,
      });
      if (response.statusCode == 201 && response.data != null) {
         final data = response.data['data'];
         if (data != null && data['id'] != null) {
           finalPost = CommunityPost(
             postId: data['id'],
             familyId: newPost.familyId,
             authorUserId: newPost.authorUserId,
             authorName: newPost.authorName,
             authorEmail: newPost.authorEmail,
             title: newPost.title,
             content: newPost.content,
             topic: newPost.topic,
             createdAt: newPost.createdAt,
             updatedAt: newPost.updatedAt,
             status: newPost.status,
             likeCount: newPost.likeCount,
             commentCount: newPost.commentCount,
             reportCount: newPost.reportCount,
             likedByUserIds: newPost.likedByUserIds,
           );
         }
      }
    } catch (e) {
      debugPrint('Community API Create Error: $e');
    }

    final posts = await getPosts();
    final existingIndex = posts.indexWhere((p) => p.postId == finalPost.postId);
    if (existingIndex >= 0) {
      posts[existingIndex] = finalPost;
    } else {
      posts.insert(0, finalPost);
    }
    await _savePosts(posts);
  }

  @override
  Future<void> updatePost(CommunityPost post) async {
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {});
    final posts = await getPosts();
    final index = posts.indexWhere((p) => p.postId == post.postId);
    if (index >= 0) {
      posts[index] = post.copyWith(updatedAt: DateTime.now());
      await _savePosts(posts);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {});
    final posts = await getPosts();
    posts.removeWhere((p) => p.postId == postId);
    await _savePosts(posts);
  }

  @override
  Future<void> likePost(String postId) async {
    String currentUserId = '';
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
    });

    final posts = await getPosts();
    final index = posts.indexWhere((p) => p.postId == postId);
    if (index >= 0) {
      final post = posts[index];
      final likedByUserIds = List<String>.from(post.likedByUserIds);
      bool alreadyLiked = likedByUserIds.contains(currentUserId);
      if (!alreadyLiked) {
        likedByUserIds.add(currentUserId);
      }
      
      final newLikeCount = likedByUserIds.length;
      posts[index] = post.copyWith(
        likedByUserIds: likedByUserIds,
        likeCount: newLikeCount,
      );

      debugPrint('================ LIKE COMMUNITY POST ================');
      debugPrint('postId: $postId');
      debugPrint('currentUserId: $currentUserId');
      debugPrint('alreadyLiked: $alreadyLiked');
      debugPrint('newLikeCount: $newLikeCount');

      await _savePosts(posts);
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    String currentUserId = '';
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
    });

    final posts = await getPosts();
    final index = posts.indexWhere((p) => p.postId == postId);
    if (index >= 0) {
      final post = posts[index];
      final likedByUserIds = List<String>.from(post.likedByUserIds);
      likedByUserIds.remove(currentUserId);
      posts[index] = post.copyWith(
        likedByUserIds: likedByUserIds,
        likeCount: likedByUserIds.length,
      );
      await _savePosts(posts);
    }
  }

  @override
  Future<List<CommunityComment>> getCommentsByPostId(String postId) async {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.communityComments);
    final rawComments = (raw?['comments'] as List<dynamic>?) ?? [];
    return rawComments
        .map((e) => CommunityComment.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((c) => c.postId == postId)
        .toList();
  }

  @override
  Future<void> createComment(CommunityComment comment) async {
    String currentUserId = '';
    String currentEmail = '';
    String currentFamilyId = '';
    String authorName = comment.authorName;

    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
      currentEmail = email;
      currentFamilyId = familyId;
      if (userName.isNotEmpty) {
        authorName = userName;
      }
    });

    final newComment = comment.copyWith(
      authorUserId: currentUserId,
      authorEmail: currentEmail,
      familyId: currentFamilyId,
      authorName: authorName,
      updatedAt: DateTime.now(),
    );

    debugPrint('================ CREATE COMMUNITY COMMENT ================');
    debugPrint('postId: ${newComment.postId}');
    debugPrint('authorUserId: ${newComment.authorUserId}');
    debugPrint('authorEmail: ${newComment.authorEmail}');
    debugPrint('content length: ${newComment.content.length}');

    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.communityComments);
    final rawComments = (raw?['comments'] as List<dynamic>?) ?? [];
    final allComments = rawComments.map((e) => CommunityComment.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    
    allComments.add(newComment);
    await hiveService.saveData(LocalKeys.communityComments, {
      'comments': allComments.map((c) => c.toJson()).toList(),
    });

    // Update comment count on post
    final posts = await getPosts();
    final postIndex = posts.indexWhere((p) => p.postId == newComment.postId);
    if (postIndex >= 0) {
      final post = posts[postIndex];
      posts[postIndex] = post.copyWith(commentCount: post.commentCount + 1);
      await _savePosts(posts);
    }
  }

  @override
  Future<void> likeComment(String commentId) async {
    String currentUserId = '';
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
    });

    final allComments = await _getAllComments();
    final index = allComments.indexWhere((c) => c.commentId == commentId);
    if (index >= 0) {
      final comment = allComments[index];
      final liked = List<String>.from(comment.likedByUserIds);
      if (!liked.contains(currentUserId)) {
        liked.add(currentUserId);
        allComments[index] = comment.copyWith(likedByUserIds: liked, likeCount: liked.length);
        await _saveComments(allComments);
      }
    }
  }

  @override
  Future<void> unlikeComment(String commentId) async {
    String currentUserId = '';
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
    });

    final allComments = await _getAllComments();
    final index = allComments.indexWhere((c) => c.commentId == commentId);
    if (index >= 0) {
      final comment = allComments[index];
      final liked = List<String>.from(comment.likedByUserIds);
      if (liked.contains(currentUserId)) {
        liked.remove(currentUserId);
        allComments[index] = comment.copyWith(likedByUserIds: liked, likeCount: liked.length);
        await _saveComments(allComments);
      }
    }
  }

  @override
  Future<void> markCommentHelpful(String commentId) async {
    String currentUserId = '';
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
    });

    final allComments = await _getAllComments();
    final index = allComments.indexWhere((c) => c.commentId == commentId);
    if (index >= 0) {
      allComments[index] = allComments[index].copyWith(
        isHelpful: true,
        markedHelpfulByUserId: currentUserId,
      );
      await _saveComments(allComments);
    }
  }

  @override
  Future<void> reportPost({required String postId, required CommunityReportReason reason, required String description}) async {
    String currentUserId = '';
    String currentEmail = '';
    await _validateRoleAndGetAuth((userId, email, userName, familyId) async {
      currentUserId = userId;
      currentEmail = email;
    });

    final report = CommunityReport(
      reportId: const Uuid().v4(),
      postId: postId,
      reporterUserId: currentUserId,
      reporterEmail: currentEmail,
      reason: reason,
      description: description,
      createdAt: DateTime.now(),
    );

    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.communityReports);
    final rawReports = (raw?['reports'] as List<dynamic>?) ?? [];
    rawReports.add(report.toJson());
    await hiveService.saveData(LocalKeys.communityReports, {'reports': rawReports});

    final posts = await getPosts();
    final postIndex = posts.indexWhere((p) => p.postId == postId);
    if (postIndex >= 0) {
      final post = posts[postIndex];
      final newReportCount = post.reportCount + 1;
      posts[postIndex] = post.copyWith(
        reportCount: newReportCount,
        status: newReportCount >= 3 ? CommunityPostStatus.flagged : post.status,
      );
      await _savePosts(posts);
    }
  }

  Future<void> _savePosts(List<CommunityPost> posts) async {
    await hiveService.saveData(LocalKeys.communityPosts, {
      'posts': posts.map((p) => p.toJson()).toList(),
    });
  }

  Future<List<CommunityComment>> _getAllComments() async {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.communityComments);
    final rawComments = (raw?['comments'] as List<dynamic>?) ?? [];
    return rawComments.map((e) => CommunityComment.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveComments(List<CommunityComment> comments) async {
    await hiveService.saveData(LocalKeys.communityComments, {
      'comments': comments.map((c) => c.toJson()).toList(),
    });
  }
}
