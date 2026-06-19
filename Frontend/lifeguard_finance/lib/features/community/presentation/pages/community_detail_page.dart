import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/community_comment.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_report.dart';
import '../bloc/community_cubit.dart';
import '../bloc/community_state.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class CommunityDetailPage extends StatelessWidget {
  final String postId;

  const CommunityDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommunityCubit>(
      create: (context) => getIt<CommunityCubit>()..loadPostDetail(postId),
      child: CommunityDetailView(postId: postId),
    );
  }
}

class CommunityDetailView extends StatefulWidget {
  final String postId;

  const CommunityDetailView({super.key, required this.postId});

  @override
  State<CommunityDetailView> createState() => _CommunityDetailViewState();
}

class _CommunityDetailViewState extends State<CommunityDetailView> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _confirmReport(BuildContext context) {
    CommunityReportReason selectedReason = CommunityReportReason.spam;
    String description = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Laporkan Postingan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih alasan laporan:'),
                  DropdownButton<CommunityReportReason>(
                    value: selectedReason,
                    isExpanded: true,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedReason = val);
                    },
                    items: CommunityReportReason.values.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()));
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Deskripsi tambahan (opsional)'),
                    onChanged: (val) => description = val,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    context.read<CommunityCubit>().reportPost(widget.postId, selectedReason, description);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Laporkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitComment(BuildContext context) {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    context.read<CommunityCubit>().createComment(widget.postId, content: content);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityCubit, CommunityState>(
      listener: (context, state) {
        if (state is CommunityActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is CommunityError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (previous, current) {
        return current is CommunityLoading || current is CommunityPostDetailLoaded || current is CommunityError;
      },
      builder: (context, state) {
        if (state is CommunityLoading || state is CommunityActionLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Detail Diskusi', style: AppTextStyles.heading3)),
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is! CommunityPostDetailLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Detail Diskusi', style: AppTextStyles.heading3)),
            body: Center(child: Text('Postingan tidak ditemukan.', style: AppTextStyles.bodyMedium)),
          );
        }

        final post = state.post;
        final comments = state.comments;

        return Scaffold(
          appBar: AppBar(
            title: Text('Detail Diskusi', style: AppTextStyles.heading3),
            actions: [
              if (post.status != CommunityPostStatus.removed)
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  tooltip: 'Laporkan postingan',
                  onPressed: () => _confirmReport(context),
                ),
            ],
          ),
          body: post.status == CommunityPostStatus.removed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Postingan ini telah dihapus oleh moderator.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          _buildPostHeader(context, post),
                          const SizedBox(height: 20),
                          Text('Komentar (${comments.length})', style: AppTextStyles.heading3),
                          const SizedBox(height: 10),
                          if (comments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text('Belum ada komentar. Jadilah yang pertama membantu!', style: AppTextStyles.bodySmall),
                            )
                          else
                            ...comments.map((c) => _buildCommentTile(context, post, c)),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Tulis komentar...',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: () => _submitComment(context),
                              icon: const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPostHeader(BuildContext context, CommunityPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (post.status == CommunityPostStatus.flagged) ...[
              const Icon(Icons.warning_amber_rounded, color: AppColors.riskCritical, size: 16),
              const SizedBox(width: 4),
            ],
            Expanded(child: Text(post.authorName, style: AppTextStyles.heading3.copyWith(fontSize: 15))),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            post.topic,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Text(post.title, style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text(post.content, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            InkWell(
              onTap: () {
                final session = getIt<AuthRepository>().getCachedSession();
                if (session != null) {
                  if (post.likedByUserIds.contains(session.currentUserId)) {
                    context.read<CommunityCubit>().unlikePost(post.postId);
                  } else {
                    context.read<CommunityCubit>().likePost(post.postId);
                  }
                }
              },
              child: Row(
                children: [
                  Icon(
                    _isLikedByMe(post) ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                    size: 16,
                    color: _isLikedByMe(post) ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text('${post.likeCount} Suka', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isLikedByMe(CommunityPost post) {
    final session = getIt<AuthRepository>().getCachedSession();
    if (session == null) return false;
    return post.likedByUserIds.contains(session.currentUserId);
  }

  Widget _buildCommentTile(BuildContext context, CommunityPost post, CommunityComment comment) {
    final session = getIt<AuthRepository>().getCachedSession();
    final isMyComment = session?.currentUserId == comment.authorUserId;
    final isPostAuthor = session?.currentUserId == post.authorUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.authorName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(comment.content, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (session != null) {
                    if (comment.likedByUserIds.contains(session.currentUserId)) {
                      context.read<CommunityCubit>().unlikeComment(post.postId, comment.commentId);
                    } else {
                      context.read<CommunityCubit>().likeComment(post.postId, comment.commentId);
                    }
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      comment.likedByUserIds.contains(session?.currentUserId) ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                      size: 14,
                      color: comment.likedByUserIds.contains(session?.currentUserId) ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text('${comment.likeCount}', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (comment.isHelpful)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.riskSafe),
                    const SizedBox(width: 4),
                    Text('Helpful', style: AppTextStyles.label.copyWith(color: AppColors.riskSafe)),
                  ],
                )
              else if (isPostAuthor && !isMyComment)
                InkWell(
                  onTap: () => context.read<CommunityCubit>().markCommentHelpful(post.postId, comment.commentId),
                  child: Text(
                    'Tandai Helpful',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
