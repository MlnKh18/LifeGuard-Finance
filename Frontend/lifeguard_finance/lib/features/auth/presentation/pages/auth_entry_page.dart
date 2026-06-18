import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai LifeGuard Finance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Pilih Metode Masuk',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Akses fitur LifeGuard Finance sesuai peran Anda dalam keluarga.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buat Akun Keluarga Baru', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    'Untuk Kepala Keluarga yang ingin membuat profil keuangan keluarga dan mengundang anggota.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Daftar Kepala Keluarga',
                    onPressed: () => context.push('/register-head'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Masuk sebagai Anggota', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    'Gunakan email dan kode undangan dari Kepala Keluarga untuk aktivasi.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Aktivasi Anggota',
                    onPressed: () => context.push('/activate-member'),
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun? ', style: AppTextStyles.bodyMedium),
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
