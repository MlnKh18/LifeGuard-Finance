import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/smart_routing_plan.dart';
import '../bloc/smart_routing_cubit.dart';
import '../bloc/smart_routing_state.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

const _allocationColors = {
  'Kebutuhan Pokok': AppColors.primary,
  'Cicilan': AppColors.riskCritical,
  'Dana Darurat': AppColors.riskWarning,
  'Pendidikan': AppColors.secondary,
  'Kesehatan': AppColors.riskVulnerable,
  'Tabungan Keluarga': AppColors.riskSafe,
};

const _allocationIcons = {
  'Kebutuhan Pokok': Icons.shopping_basket_rounded,
  'Cicilan': Icons.credit_card_rounded,
  'Dana Darurat': Icons.shield_rounded,
  'Pendidikan': Icons.school_rounded,
  'Kesehatan': Icons.local_hospital_rounded,
  'Tabungan Keluarga': Icons.savings_rounded,
};

class SmartRoutingPage extends StatelessWidget {
  const SmartRoutingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SmartRoutingCubit>(
      create: (context) => getIt<SmartRoutingCubit>()..loadPlan(),
      child: const SmartRoutingView(),
    );
  }
}

class SmartRoutingView extends StatelessWidget {
  const SmartRoutingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Routing', style: AppTextStyles.heading3)),
      body: BlocBuilder<SmartRoutingCubit, SmartRoutingState>(
        builder: (context, state) {
          if (state is SmartRoutingLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is SmartRoutingNoProfile) {
            return _buildNoProfileView(context);
          }
          if (state is SmartRoutingError) {
            return _buildErrorView(context, state.message);
          }
          if (state is SmartRoutingLoaded) {
            return _buildContent(context, state.plan);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SmartRoutingPlan plan) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionTitle(
          title: 'Goal-Driven Smart Routing',
          subtitle: 'Panduan alokasi pendapatan bulanan berdasarkan kategori vitalitas finansial Anda saat ini.',
        ),
        const SizedBox(height: 8),
        AppCard(
          showShadow: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Pendapatan Bulanan', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Text(_rupiahFormat.format(plan.totalIncome), style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _categoryColor(plan.fvsCategory).withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Kategori: ${plan.fvsCategory}',
                  style: AppTextStyles.bodySmall.copyWith(color: _categoryColor(plan.fvsCategory), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            children: [
              Text('Distribusi Alokasi Dana', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: plan.allocations
                        .where((a) => a.percentage > 0)
                        .map((a) => PieChartSectionData(
                              value: a.percentage,
                              color: _allocationColors[a.category] ?? AppColors.textSecondary,
                              title: '${a.percentage.toStringAsFixed(0)}%',
                              radius: 56,
                              titleStyle: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Rincian Pos Alokasi', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        ...plan.allocations.map((a) => _buildAllocationTile(a)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.tertiaryContainer.withAlpha(80)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.tertiaryContainer, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Catatan: Alokasi ini adalah rekomendasi edukatif berbasis kategori FVS Anda, bukan nasihat keuangan profesional. Sesuaikan dengan kondisi keluarga Anda.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Buat Pos Dana Darurat di Savings Vault',
          icon: const Icon(Icons.savings_rounded, color: Colors.white, size: 18),
          onPressed: () => context.push('/savings-vault'),
        ),
      ],
    );
  }

  Widget _buildAllocationTile(SmartRoutingAllocation allocation) {
    final color = _allocationColors[allocation.category] ?? AppColors.textSecondary;
    final icon = _allocationIcons[allocation.category] ?? Icons.pie_chart_rounded;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 8.0,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withAlpha(26), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(allocation.category, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: allocation.percentage / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${allocation.percentage.toStringAsFixed(1)}%', style: AppTextStyles.dataLabel.copyWith(color: color)),
              Text(_rupiahFormat.format(allocation.amount), style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Aman':
        return AppColors.riskSafe;
      case 'Waspada':
        return AppColors.riskWarning;
      case 'Rentan':
        return AppColors.riskVulnerable;
      default:
        return AppColors.riskCritical;
    }
  }

  Widget _buildNoProfileView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom_rounded, size: 100, color: AppColors.border),
          const SizedBox(height: 24),
          Text('Profil Keuangan Belum Lengkap', style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Lengkapi data profil keuangan keluarga terlebih dahulu untuk mendapatkan rencana alokasi dana yang dipersonalisasi.',
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
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: () => context.read<SmartRoutingCubit>().loadPlan(),
          ),
        ],
      ),
    );
  }
}
