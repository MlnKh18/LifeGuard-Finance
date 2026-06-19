import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/early_warning.dart';
import '../bloc/notification_cubit.dart';
import '../bloc/notification_state.dart';

Color _severityColor(EarlyWarningSeverity severity) {
  switch (severity) {
    case EarlyWarningSeverity.high:
      return AppColors.riskCritical;
    case EarlyWarningSeverity.medium:
      return AppColors.riskWarning;
    case EarlyWarningSeverity.low:
      return AppColors.secondary;
  }
}

IconData _severityIcon(EarlyWarningSeverity severity) {
  switch (severity) {
    case EarlyWarningSeverity.high:
      return Icons.error_rounded;
    case EarlyWarningSeverity.medium:
      return Icons.warning_amber_rounded;
    case EarlyWarningSeverity.low:
      return Icons.info_rounded;
  }
}

class EarlyWarningPage extends StatelessWidget {
  const EarlyWarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (context) => getIt<NotificationCubit>()..loadWarnings(),
      child: const EarlyWarningView(),
    );
  }
}

class EarlyWarningView extends StatelessWidget {
  const EarlyWarningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sistem Peringatan Dini', style: AppTextStyles.heading3)),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is NotificationNoProfile) {
            return _buildNoProfileView(context);
          }
          if (state is NotificationError) {
            return _buildErrorView(context, state.message);
          }
          if (state is NotificationLoaded) {
            return _buildContent(context, state.warnings);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<EarlyWarning> warnings) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SectionTitle(
          title: 'Peringatan Dini',
          subtitle: warnings.isEmpty
              ? 'Tidak ada peringatan aktif. Kondisi keuangan Anda terpantau baik.'
              : '${warnings.length} peringatan aktif terdeteksi dari data keuangan Anda.',
        ),
        const SizedBox(height: 16),
        if (warnings.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.verified_rounded, size: 56, color: AppColors.riskSafe),
                const SizedBox(height: 12),
                Text('Semua Aman', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(
                  'Tidak ada trigger peringatan yang aktif saat ini.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...warnings.map((w) => _buildWarningCard(w)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _requestPermission(context),
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Izinkan Notifikasi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                text: 'Tes Notifikasi',
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: warnings.isEmpty ? null : () => _sendTestNotifications(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWarningCard(EarlyWarning warning) {
    final color = _severityColor(warning.severity);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 12.0,
      color: color.withAlpha(15),
      border: Border.all(color: color.withAlpha(100)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_severityIcon(warning.severity), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(warning.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(warning.message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    final cubit = context.read<NotificationCubit>();
    final granted = await cubit.requestPermission();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(granted ? 'Izin notifikasi diberikan.' : 'Izin notifikasi ditolak.'),
        backgroundColor: granted ? AppColors.riskSafe : AppColors.riskCritical,
      ),
    );
  }

  Future<void> _sendTestNotifications(BuildContext context) async {
    final cubit = context.read<NotificationCubit>();
    await cubit.sendTestNotifications();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi peringatan telah dikirim.'), backgroundColor: AppColors.primary),
    );
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
            'Lengkapi data profil keuangan keluarga terlebih dahulu untuk memantau peringatan dini.',
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
            onPressed: () => context.read<NotificationCubit>().loadWarnings(),
          ),
        ],
      ),
    );
  }
}
