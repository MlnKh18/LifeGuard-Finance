import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../bloc/fvs_bloc.dart';
import '../bloc/fvs_event.dart';
import '../bloc/fvs_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/core/permission_helper.dart';
import '../widgets/score_card.dart';
import '../widgets/indicator_breakdown.dart';
import '../widgets/metric_bento_card.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FvsBloc>(
      create: (context) => getIt<FvsBloc>()..add(LoadFvs()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LifeGuard Finance', style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<FvsBloc, FvsState>(
        builder: (context, state) {
          if (state is FvsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is FvsNoProfile) {
            return _buildNoProfileView(context);
          }

          if (state is FvsError) {
            return _buildErrorView(context, state.message);
          }

          if (state is FvsLoaded) {
            return _buildDashboardContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNoProfileView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.family_restroom_rounded,
            size: 100,
            color: AppColors.border,
          ),
          const SizedBox(height: 24),
          Text(
            'Profil Keuangan Belum Lengkap',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Untuk menghitung Financial Vulnerability Score (FVS), Anda perlu melengkapi profil keuangan keluarga Anda terlebih dahulu.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Lengkapi Profil Sekarang',
            onPressed: () => context.go('/family-profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: () => context.read<FvsBloc>().add(LoadFvs()),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, FvsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FvsBloc>().add(CalculateFvs());
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String greeting = 'Halo, Keluarga';
                if (authState is AuthAuthenticated) {
                  greeting = 'Halo, ${authState.user.fullName}';
                  if (PermissionHelper.isFamilyMember(authState.session.currentUserRole)) {
                    greeting += ' (Mode Anggota Keluarga)';
                  }
                }
                return SectionTitle(
                  title: greeting,
                  subtitle: 'Berikut adalah ringkasan kesehatan finansial Anda hari ini.',
                );
              },
            ),
            const SizedBox(height: 12),

            // Vitality Score Card
            ScoreCard(fvsScore: state.score),
            const SizedBox(height: 20),

            // Bento Grid for Metrics
            _buildMetricGrid(state.profile),
            const SizedBox(height: 20),

            // Feature Link: Catatan Harian
            _buildFeatureLinkCard(
              context: context,
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.primary,
              title: 'Catatan Harian',
              subtitle: 'Catat pengeluaran & pemasukan sehari-hari',
              onTap: () => context.push('/daily-finance'),
            ),
            const SizedBox(height: 12),

            // Feature Link: Simulasi Sandbox
            _buildFeatureLinkCard(
              context: context,
              icon: Icons.science_rounded,
              iconColor: AppColors.primary,
              title: 'Uji Ketahanan (Simulasi Sandbox)',
              subtitle: 'Simulasikan dampak krisis pada keuangan Anda',
              onTap: () => context.push('/simulation'),
            ),
            const SizedBox(height: 12),

            // Feature Link: Rekomendasi
            _buildFeatureLinkCard(
              context: context,
              icon: Icons.shield_rounded,
              iconColor: AppColors.secondary,
              title: 'Deteksi Anomali',
              subtitle: 'Lihat peringatan pengeluaran tidak wajar',
              onTap: () => context.push('/expense-anomaly'),
            ),
            const SizedBox(height: 12),

            // Feature Link: Peringatan Dini
            _buildFeatureLinkCard(
              context: context,
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.riskWarning,
              title: 'Peringatan Dini',
              subtitle: 'Pantau trigger risiko keuangan keluarga Anda',
              onTap: () => context.push('/early-warning'),
            ),
            const SizedBox(height: 24),

            // Action Button
            PrimaryButton(
              text: 'Perbarui Target Keuangan',
              icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
              onPressed: () => context.go('/family-profile'),
            ),
            const SizedBox(height: 28),

            Text('Breakdown Indikator (S1-S7)', style: AppTextStyles.heading2),
            const SizedBox(height: 12),

            // Indicator breakdown list widget
            IndicatorBreakdown(fvsScore: state.score),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid(FamilyFinanceProfile profile) {
    final totalIncome = profile.fixedIncome + profile.variableIncome;
    final emergencyTarget = profile.routineExpenses * 6;
    final monthsCovered = profile.routineExpenses > 0
        ? profile.liquidSavings / profile.routineExpenses
        : 0.0;
    final debtRatio = totalIncome > 0 ? profile.debtPayments / totalIncome : 0.0;
    final surplus = totalIncome - profile.routineExpenses - profile.debtPayments;
    final savingsRatio = totalIncome > 0 ? (surplus / totalIncome).clamp(0.0, 1.0) : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        MetricBentoCard(
          icon: Icons.warning_amber_rounded,
          title: 'Dana Darurat',
          value: '${monthsCovered.toStringAsFixed(1)} Bulan',
          accentColor: monthsCovered >= 6
              ? AppColors.riskSafe
              : monthsCovered >= 3
                  ? AppColors.riskWarning
                  : AppColors.riskCritical,
          progress: emergencyTarget > 0 ? profile.liquidSavings / emergencyTarget : 0,
          targetLabel: 'Target: 6 Bulan',
          statusLabel: monthsCovered >= 6 ? 'Tercapai' : 'Perlu Ditingkatkan',
        ),
        MetricBentoCard(
          icon: Icons.credit_card_rounded,
          title: 'Rasio Hutang',
          value: '${(debtRatio * 100).toStringAsFixed(0)}%',
          accentColor: debtRatio <= 0.3 ? AppColors.riskSafe : AppColors.riskCritical,
          progress: debtRatio,
          targetLabel: 'Target: < 30%',
          statusLabel: debtRatio <= 0.3 ? 'Sehat' : 'Tinggi',
        ),
        MetricBentoCard(
          icon: Icons.savings_rounded,
          title: 'Rasio Menabung',
          value: '${(savingsRatio * 100).toStringAsFixed(0)}%',
          accentColor: savingsRatio >= 0.2 ? AppColors.riskSafe : AppColors.riskWarning,
          progress: savingsRatio,
          targetLabel: 'Target: > 20%',
          statusLabel: savingsRatio >= 0.2 ? 'Baik' : 'Perlu Ditingkatkan',
        ),
        MetricBentoCard(
          icon: Icons.account_balance_rounded,
          title: 'Aset Likuid',
          value: _rupiahFormat.format(profile.liquidSavings),
          accentColor: AppColors.secondary,
          progress: emergencyTarget > 0 ? profile.liquidSavings / emergencyTarget : 0,
          targetLabel: 'Target: ${_rupiahFormat.format(emergencyTarget)}',
          statusLabel: profile.liquidSavings >= emergencyTarget ? 'Tercapai' : 'On Track',
        ),
      ],
    );
  }

  Widget _buildFeatureLinkCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
