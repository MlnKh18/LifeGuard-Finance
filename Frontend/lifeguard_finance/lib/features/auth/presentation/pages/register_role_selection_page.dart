import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';

class RegisterRoleSelectionPage extends StatelessWidget {
  const RegisterRoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Peran'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.family_restroom, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Selamat Datang di LifeGuard', style: AppTextStyles.heading2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Silakan pilih peran Anda dalam keluarga', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              AppCard(
                onTap: () => context.push('/register-head'),
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.manage_accounts, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kepala Keluarga', style: AppTextStyles.heading3),
                          Text('Kelola keuangan dan anggota keluarga', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                onTap: () => context.push('/login'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anggota Keluarga', style: AppTextStyles.heading3),
                          Text('Masuk menggunakan akun dari kepala keluarga', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?'),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text('Masuk di sini', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
