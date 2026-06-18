import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/fvs_status_card.dart';
import '../widgets/family_protection_card.dart';
import '../widgets/savings_vault_summary_card.dart';
import '../widgets/literacy_progress_card.dart';
import '../widgets/community_reward_summary_card.dart';
import '../widgets/privacy_settings_section.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(LoadProfileSummary()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Profil & Pengaturan', style: AppTextStyles.heading2),
          centerTitle: false,
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileClearSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data lokal berhasil dihapus.'),
                  backgroundColor: AppColors.riskSafe,
                ),
              );
              context.go('/onboarding');
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terjadi kesalahan: '),
                  backgroundColor: AppColors.riskCritical,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is ProfileLoaded) {
              final summary = state.summary;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(LoadProfileSummary());
                },
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ProfileHeaderCard(
                      userName: summary.userName,
                      email: summary.email,
                      activeBadge: summary.activeBadge,
                      totalRewardPoints: summary.totalRewardPoints,
                    ),
                    const SizedBox(height: 16),
                    FinancialSummaryCard(
                      totalIncome: summary.totalIncome,
                      monthlyExpense: summary.monthlyExpense,
                      monthlyDebtPayment: summary.monthlyDebtPayment,
                      liquidSavings: summary.liquidSavings,
                    ),
                    const SizedBox(height: 16),
                    FvsStatusCard(
                      score: summary.latestFvsScore,
                      category: summary.latestFvsCategory,
                    ),
                    const SizedBox(height: 16),
                    FamilyProtectionCard(
                      dependentsCount: summary.dependentsCount,
                      hasBpjs: summary.hasBpjs,
                      hasInsurance: summary.hasInsurance,
                    ),
                    const SizedBox(height: 16),
                    SavingsVaultSummaryCard(
                      vaultCount: summary.vaultCount,
                      totalVaultTarget: summary.totalVaultTarget,
                      totalVaultSaved: summary.totalVaultSaved,
                      averageVaultProgress: summary.averageVaultProgress,
                    ),
                    const SizedBox(height: 16),
                    LiteracyProgressCard(
                      readCount: summary.literacyReadCount,
                      totalCount: summary.literacyTotalCount,
                    ),
                    const SizedBox(height: 16),
                    CommunityRewardSummaryCard(
                      postCount: summary.communityPostCount,
                      commentCount: summary.communityCommentCount,
                      totalRewardPoints: summary.totalRewardPoints,
                      activeBadge: summary.activeBadge,
                    ),
                    const SizedBox(height: 24),
                    Text('Pengaturan & Privasi', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    const PrivacySettingsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Gagal memuat profil.'));
            }
          },
        ),
      ),
    );
  }
}
