import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../bloc/fvs_bloc.dart';
import '../bloc/fvs_event.dart';
import '../bloc/fvs_state.dart';
import '../widgets/score_card.dart';
import '../widgets/indicator_breakdown.dart';

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
        title: const Text('FVS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/profile-settings'),
          ),
        ],
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
          const Text(
            'Profil Keuangan Belum Lengkap',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
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
          const Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
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
            const SectionTitle(
              title: 'Analisis Kesehatan Finansial',
              subtitle: 'Skor kerentanan finansial keluarga Anda berdasarkan formula edukatif LifeGuard.',
            ),
            const SizedBox(height: 12),
            
            // Score Card widget
            ScoreCard(fvsScore: state.score),
            const SizedBox(height: 20),

            // Action CTAs
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => context.push('/simulation'),
                    child: Column(
                      children: const [
                        Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 28),
                        SizedBox(height: 8),
                        Text('Simulasi Skenario', style: AppTextStyles.heading3, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => context.push('/recommendation'),
                    child: Column(
                      children: const [
                        Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 28),
                        SizedBox(height: 8),
                        Text('Rekomendasi', style: AppTextStyles.heading3, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Breakdown Indikator (S1-S7)', style: AppTextStyles.heading2),
                TextButton(
                  onPressed: () => context.go('/family-profile'),
                  child: const Text('Update Profil', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Indicator breakdown list widget
            IndicatorBreakdown(fvsScore: state.score),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
