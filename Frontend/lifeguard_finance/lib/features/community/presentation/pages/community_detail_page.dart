import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/community_comment.dart';
import '../../domain/entities/community_post.dart';
import '../bloc/community_cubit.dart';
import '../bloc/community_state.dart';

class CommunityDetailPage extends StatelessWidget {
  final String postId;

  const CommunityDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommunityCubit>(
      create: (context) => getIt<CommunityCubit>()..loadFeed(),
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Laporkan Postingan'),
        content: const Text('Postingan ini akan ditandai untuk ditinjau moderator. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<CommunityCubit>().reportPost(widget.postId);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }

  void _submitComment(BuildContext context) {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    context.read<CommunityCubit>().addComment(widget.postId, content: content);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Detail Diskusi', style: AppTextStyles.heading3)),
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is! CommunityLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Detail Diskusi', style: AppTextStyles.heading3)),
            body: Center(child: Text('Postingan tidak ditemukan.', style: AppTextStyles.bodyMedium)),
          );
        }

        final matches = state.posts.where((p) => p.id == widget.postId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Detail Diskusi', style: AppTextStyles.heading3)),
            body: Center(child: Text('Postingan tidak ditemukan.', style: AppTextStyles.bodyMedium)),
          );
        }
        final post = matches.first;

        return Scaffold(
          appBar: AppBar(
            title: Text('Detail Diskusi', style: AppTextStyles.heading3),
            actions: [
              if (post.status != PostStatus.removed)
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  tooltip: 'Laporkan postingan',
                  onPressed: () => _confirmReport(context),
                ),
            ],
          ),
          body: post.status == PostStatus.removed
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
                          _buildPostHeader(post),
                          const SizedBox(height: 20),
                          Text('Komentar (${post.commentCount})', style: AppTextStyles.heading3),
                          const SizedBox(height: 10),
                          if (post.comments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text('Belum ada komentar. Jadilah yang pertama membantu!', style: AppTextStyles.bodySmall),
                            )
                          else
                            ...post.comments.map((c) => _buildCommentTile(context, post.id, c)),
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

  Widget _buildPostHeader(CommunityPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (post.status == PostStatus.flagged) ...[
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
            post.category,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Text(post.content, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            InkWell(
              onTap: () => context.read<CommunityCubit>().toggleLike(post.id),
              child: Row(
                children: [
                  Icon(
                    post.isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                    size: 16,
                    color: post.isLiked ? AppColors.primary : AppColors.textSecondary,
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

  Widget _buildCommentTile(BuildContext context, String postId, CommunityComment comment) {
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
              if (comment.isHelpful)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.riskSafe),
                    const SizedBox(width: 4),
                    Text('Helpful', style: AppTextStyles.label.copyWith(color: AppColors.riskSafe)),
                  ],
                )
              else
                InkWell(
                  onTap: () => context.read<CommunityCubit>().markCommentHelpful(postId, comment.id),
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
