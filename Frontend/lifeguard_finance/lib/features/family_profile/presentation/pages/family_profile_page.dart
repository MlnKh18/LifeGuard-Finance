import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';

class FamilyProfilePage extends StatelessWidget {
  const FamilyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Keuangan Keluarga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lengkapi Profil Keuangan', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            const Text(
              'Profil ini akan digunakan untuk menghitung Financial Vulnerability Score (FVS) keluarga Anda.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Pendapatan Bulanan (Rp)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Pengeluaran Bulanan (Rp)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Anggota Keluarga',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Simpan & Lihat Dashboard',
                    onPressed: () {
                      context.go('/dashboard');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
