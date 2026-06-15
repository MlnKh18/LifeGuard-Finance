import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/risk_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeGuard Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/profile-settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Halo, Keluarga Rian!',
              subtitle: 'Skor kerentanan finansial Anda terupdate hari ini.',
            ),
            const SizedBox(height: 12),
            
            // FVS Card
            AppCard(
              showShadow: true,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Financial Vulnerability Score (FVS)', style: AppTextStyles.heading3),
                      RiskBadge(level: RiskLevel.warning),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Skor Anda: 65 / 100 (Waspada)',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.riskWarning),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Uji Skenario Darurat',
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                    onPressed: () {
                      context.push('/simulation');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const SectionTitle(title: 'Fitur Utama Mitigasi'),
            const SizedBox(height: 8),
            
            // Grid features placeholder
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildFeatureItem(
                  context,
                  title: 'Rekomendasi',
                  icon: Icons.lightbulb_outline_rounded,
                  route: '/recommendation',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Smart Routing',
                  icon: Icons.alt_route_rounded,
                  route: '/smart-routing',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Anomali Biaya',
                  icon: Icons.analytics_outlined,
                  route: '/expense-anomaly',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Sistem Peringatan',
                  icon: Icons.notifications_active_outlined,
                  route: '/early-warning',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Literasi Finansial',
                  icon: Icons.menu_book_rounded,
                  route: '/literacy',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Tabungan Vault',
                  icon: Icons.savings_outlined,
                  route: '/savings-vault',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Komunitas',
                  icon: Icons.people_outline_rounded,
                  route: '/community',
                ),
                _buildFeatureItem(
                  context,
                  title: 'Reward Points',
                  icon: Icons.emoji_events_outlined,
                  route: '/reward',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
