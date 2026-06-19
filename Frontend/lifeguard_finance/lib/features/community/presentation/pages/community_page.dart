import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/community_post.dart';
import '../bloc/community_cubit.dart';
import '../bloc/community_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/core/permission_helper.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          if (!PermissionHelper.canAccessCommunity(authState.session.currentUserRole)) {
            return const Scaffold(
              body: AccessDeniedWidget(),
            );
          }
        }
        
        return BlocProvider<CommunityCubit>(
          create: (context) => getIt<CommunityCubit>()..loadPosts(),
          child: const CommunityView(),
        );
      },
    );
  }
}

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  @override
  Widget build(BuildContext context) {
    debugPrint('================ COMMUNITY PAGE OPENED ================');
    return Scaffold(
      appBar: AppBar(
        title: Text('Community', style: AppTextStyles.heading3),
      ),
      body: BlocConsumer<CommunityCubit, CommunityState>(
        listener: (context, state) {
          if (state is CommunityActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CommunityError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CommunityAccessDenied) {
            context.go('/access-denied');
          }
        },
        buildWhen: (previous, current) {
          return current is CommunityLoading || current is CommunityLoaded || current is CommunityError;
        },
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is CommunityError) {
            return _buildErrorView(context, state.message);
          }

          if (state is CommunityLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddPostDialog(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Buat Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CommunityLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<CommunityCubit>().loadPosts(topic: state.selectedTopic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildTopicChips(context, state),
          const SizedBox(height: 16),
          if (state.posts.isEmpty)
            _buildEmptyState()
          else
            ...state.posts.map((post) => _buildPostCard(context, post)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Ruang diskusi Kepala Keluarga', style: AppTextStyles.heading2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Khusus Kepala Keluarga',
                  style: AppTextStyles.label.copyWith(color: AppColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bagikan pengalaman, strategi, dan pertanyaan seputar pengelolaan keuangan keluarga.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChips(BuildContext context, CommunityLoaded state) {
    final topics = ['Semua', ...communityCategories];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: topics.map((topic) {
          final isSelected = state.selectedTopic == topic;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(topic),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<CommunityCubit>().loadPosts(topic: topic);
                }
              },
              backgroundColor: AppColors.surfaceContainerLow,
              selectedColor: AppColors.primaryContainer,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.forum_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Belum ada diskusi komunitas.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    if (post.status == CommunityPostStatus.removed) return const SizedBox.shrink();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/community/${post.postId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: post.authorName.hashCode.isEven ? AppColors.primary.withAlpha(38) : AppColors.tertiaryContainer,
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                  style: AppTextStyles.heading3.copyWith(
                    color: post.authorName.hashCode.isEven ? AppColors.primary : AppColors.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (post.status == CommunityPostStatus.flagged) ...[
                          const Icon(Icons.warning_amber_rounded, color: AppColors.riskCritical, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Expanded(child: Text(post.authorName, style: AppTextStyles.heading3.copyWith(fontSize: 14))),
                        Text(_timeAgo(post.createdAt), style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: post.status == CommunityPostStatus.flagged ? AppColors.errorContainer : AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.topic,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: post.status == CommunityPostStatus.flagged ? AppColors.onErrorContainer : AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.title, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            post.content,
            style: AppTextStyles.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 6),
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
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${post.commentCount} Balasan', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isLikedByMe(CommunityPost post) {
    final session = getIt<AuthRepository>().getCachedSession();
    if (session == null) return false;
    return post.likedByUserIds.contains(session.currentUserId);
  }

  void _showAddPostDialog(BuildContext context) {
    final cubit = context.read<CommunityCubit>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = communityCategories.first;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Post Community', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text('Bagikan pertanyaan atau pengalaman terkait pengelolaan keuangan keluarga.', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Topik',
                    border: OutlineInputBorder(),
                  ),
                  items: communityCategories.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => category = val ?? category,
                  validator: (val) => val == null ? 'Topik wajib dipilih' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Judul wajib diisi';
                    if (val.trim().length < 5) return 'Judul minimal 5 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Isi Post',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Isi post wajib diisi';
                    if (val.trim().length < 20) return 'Isi post minimal 20 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Publikasikan',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      debugPrint('================ CREATE COMMUNITY POST SUBMIT ================');
                      debugPrint('title: ${titleController.text}');
                      debugPrint('topic: $category');
                      
                      cubit.createPost(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        topic: category,
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}
