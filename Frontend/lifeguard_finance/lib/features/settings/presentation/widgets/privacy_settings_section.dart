import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/core/permission_helper.dart';

class PrivacySettingsSection extends StatelessWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool isHead = false;
        if (authState is AuthAuthenticated) {
          isHead = PermissionHelper.isHeadOfFamily(authState.session.currentUserRole);
        }

        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (isHead) ...[
                _buildListTile(
                  context,
                  icon: Icons.group_add,
                  title: 'Kelola Anggota Keluarga',
                  onTap: () => context.push('/family-members'),
                ),
                const Divider(height: 1, indent: 56),
              ],
              _buildListTile(
                context,
                icon: Icons.edit_note,
                title: 'Edit Profil Keuangan',
                onTap: () => context.push('/family-profile'),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context,
                icon: Icons.dashboard,
                title: 'Lihat Dashboard FVS',
                onTap: () => context.push('/dashboard'),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Data & Privasi',
                onTap: () => _showPrivacyDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context,
                icon: Icons.info_outline,
                title: 'Tentang LifeGuard Finance',
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context,
                icon: Icons.logout,
                title: 'Keluar (Logout)',
                titleColor: AppColors.riskWarning,
                iconColor: AppColors.riskWarning,
                onTap: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go('/login');
                },
              ),
              if (isHead) ...[
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Hapus Data Lokal',
                  titleColor: AppColors.riskCritical,
                  iconColor: AppColors.riskCritical,
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color titleColor = AppColors.textPrimary,
    Color iconColor = AppColors.textSecondary,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: titleColor)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Data & Privasi', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPrivacyItem('Data disimpan secara lokal pada perangkat untuk prototype.'),
            _buildPrivacyItem('Aplikasi tidak meminta akses rekening bank.'),
            _buildPrivacyItem('FVS bersifat edukatif dan simulatif, bukan prediksi mutlak.'),
            _buildPrivacyItem('Aplikasi bukan produk pinjaman atau investasi.'),
            _buildPrivacyItem('Aplikasi bukan pengganti konsultan keuangan profesional.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tentang LifeGuard Finance', style: AppTextStyles.heading3),
        content: Text(
          'LifeGuard Finance adalah aplikasi fintech preventif untuk membantu keluarga mengukur kerentanan finansial, menjalankan simulasi krisis, dan mendapatkan rekomendasi.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Data Lokal?', style: AppTextStyles.heading3.copyWith(color: AppColors.riskCritical)),
        content: Text(
          'Semua data profile, skor, simulasi, vault, literasi, komunitas, dan reward yang tersimpan di perangkat akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskCritical, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              context.read<ProfileBloc>().add(ClearProfileLocalData());
            },
            child: const Text('Hapus Data'),
          ),
        ],
      ),
    );
  }
}
