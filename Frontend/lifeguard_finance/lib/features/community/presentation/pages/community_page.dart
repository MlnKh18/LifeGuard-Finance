import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/community_challenge.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/community_progress.dart';
import '../bloc/community_cubit.dart';
import '../bloc/community_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/core/permission_helper.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';

const _availableTags = ['#SandwichGeneration', '#EmergencyFund', '#Menabung', '#Investasi'];

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
          create: (context) => getIt<CommunityCubit>()..loadFeed(),
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
  String? _tagFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Komunitas', style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<CommunityCubit, CommunityState>(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddPostDialog(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CommunityLoaded state) {
    final visiblePosts = _tagFilter == null
        ? state.posts
        : state.posts.where((p) => p.tag == _tagFilter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Text('Komunitas', style: AppTextStyles.heading1.copyWith(fontSize: 32)),
        const SizedBox(height: 4),
        Text('Belajar bersama, tumbuh bersama.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 16),
        _buildProgressCard(state.progress),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Diskusi Terbaru', style: AppTextStyles.heading2),
            PopupMenuButton<String?>(
              initialValue: _tagFilter,
              onSelected: (value) => setState(() => _tagFilter = value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: null, child: Text('Semua Topik')),
                ..._availableTags.map((t) => PopupMenuItem(value: t, child: Text(t))),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tagFilter ?? 'Filter',
                    style: AppTextStyles.dataLabel.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...visiblePosts.map((post) => _buildPostCard(context, post)),
        const SizedBox(height: 24),
        Text('Tantangan Aktif', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        ...state.challenges.map((challenge) => _buildChallengeCard(context, challenge)),
      ],
    );
  }

  Widget _buildProgressCard(CommunityProgress progress) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Perjalanan', style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text(
                '${progress.xp} XP',
                style: AppTextStyles.dataDisplay.copyWith(fontSize: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  progress.badge,
                  style: AppTextStyles.label.copyWith(color: AppColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target Mingguan', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${progress.weeklyGoalCurrent}/${progress.weeklyGoalTotal}',
                      style: AppTextStyles.dataLabel.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.weeklyGoalTotal > 0 ? progress.weeklyGoalCurrent / progress.weeklyGoalTotal : 0,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selesaikan ${(progress.weeklyGoalTotal - progress.weeklyGoalCurrent).clamp(0, progress.weeklyGoalTotal)} misi lagi untuk bonus XP.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
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
                        if (post.isFlagged) ...[
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
                        color: post.isFlagged ? AppColors.errorContainer : AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.tag,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: post.isFlagged ? AppColors.onErrorContainer : AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.content, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 6),
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

  Widget _buildChallengeCard(BuildContext context, CommunityChallenge challenge) {
    if (challenge.isPrimary) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(challenge.title, style: AppTextStyles.heading3.copyWith(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Text(challenge.description, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha(220))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progres', style: AppTextStyles.label.copyWith(color: Colors.white.withAlpha(200))),
                Text(
                  'Hari ${challenge.progressCurrent}/${challenge.progressTotal}',
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: challenge.progress,
                minHeight: 5,
                backgroundColor: Colors.white.withAlpha(50),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: challenge.isCompleted ? 'Selesai' : 'Check-in Hari Ini',
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                onPressed: challenge.isCompleted
                    ? null
                    : () => context.read<CommunityCubit>().progressChallenge(challenge.id),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 8.0,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  challenge.isCompleted ? 'Selesai' : '+${challenge.xpReward} XP',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: challenge.isCompleted
                ? null
                : () => context.read<CommunityCubit>().progressChallenge(challenge.id),
            icon: Icon(
              challenge.isCompleted ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    final cubit = context.read<CommunityCubit>();
    final contentController = TextEditingController();
    String tag = _availableTags.first;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Diskusi Baru'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Apa yang ingin Anda bagikan?'),
                      maxLines: 3,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Konten wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: tag,
                      decoration: const InputDecoration(labelText: 'Topik'),
                      items: _availableTags.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setDialogState(() => tag = val ?? tag),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    cubit.addPost(content: contentController.text.trim(), tag: tag);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Posting'),
                ),
              ],
            );
          },
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
