import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/widgets/primary_button.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/section_title.dart';
import 'core/widgets/risk_badge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeGuard Finance',
      theme: AppTheme.lightTheme,
      home: const DemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeGuard Finance System'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Design System Showcase',
              subtitle: 'Implementasi komponen UI dasar LifeGuard Finance',
            ),
            const SizedBox(height: 16),
            
            // AppCard - Vulnerability Score Card
            AppCard(
              showShadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Financial Vulnerability Score',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const RiskBadge(level: RiskLevel.warning),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Skor kerentanan finansial keluarga Anda saat ini berada di tingkat Waspada. Anda disarankan untuk menambah dana darurat.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Simulasikan Dana Darurat',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulasi Dana Darurat Dipicu'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const SectionTitle(
              title: 'Tingkat Risiko (Risk Badges)',
              subtitle: 'Badge penanda tingkat kerentanan keluarga',
            ),
            const SizedBox(height: 12),
            
            // Risk Badges Display
            AppCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  RiskBadge(level: RiskLevel.safe),
                  RiskBadge(level: RiskLevel.warning),
                  RiskBadge(level: RiskLevel.vulnerable),
                  RiskBadge(level: RiskLevel.critical),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SectionTitle(
              title: 'Variasi Tombol (Buttons)',
              subtitle: 'Reusable button dengan berbagai state',
            ),
            const SizedBox(height: 12),
            
            AppCard(
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Tombol Utama (Primary)',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Tombol dengan Icon',
                    icon: const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Loading State',
                    isLoading: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  const PrimaryButton(
                    text: 'Disabled Button',
                    onPressed: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
