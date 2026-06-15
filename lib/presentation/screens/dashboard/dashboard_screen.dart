import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';
import '../../widgets/circular_gauge.dart';
import '../../widgets/indicator_card.dart';
import '../settings/settings_screen.dart';
import '../action_plan/action_plan_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Currency Formatter
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStateProvider);
    final score = ref.watch(fvsStateProvider);
    final notifications = ref.watch(notificationsProvider);
    final unreadNotifs = notifications.where((n) => n['is_read'] == 0).toList();

    if (profile == null || score == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculations for quick metrics
    final double savingsRate = profile.monthlyIncome > 0
        ? ((profile.monthlyIncome - profile.monthlyExpense) / profile.monthlyIncome) * 100
        : 0.0;
    final double debtRatio = profile.monthlyIncome > 0
        ? (profile.monthlyDebtPayment / profile.monthlyIncome) * 100
        : 0.0;
    final double emergencyMonths = profile.monthlyExpense > 0
        ? profile.liquidSavings / profile.monthlyExpense
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeGuard Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.clipboardList),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActionPlanScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell),
                onPressed: () {
                  _showNotificationsBottomSheet(context, ref, notifications);
                },
              ),
              if (unreadNotifs.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.critical,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.m, vertical: AppStyles.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildGreetingCard(profile),
            const SizedBox(height: AppStyles.m),

            // Early Warning Alert Banner
            if (unreadNotifs.isNotEmpty) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.critical.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                  border: Border.all(color: AppColors.critical.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Peringatan Dini Keuangan',
                            style: TextStyle(
                              color: AppColors.critical,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            unreadNotifs.first['message'],
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 20),
                      onPressed: () {
                        ref.read(notificationsProvider.notifier).markAsRead(unreadNotifs.first['notification_id']);
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.m),
            ],

            // Gauge Card
            Center(
              child: CircularGauge(score: score.totalScore),
            ),
            const SizedBox(height: AppStyles.m),

            // Summary Stats Row
            Row(
              children: [
                _buildStatWidget(
                  label: 'Savings Rate',
                  value: '${savingsRate.toStringAsFixed(0)}%',
                  icon: LucideIcons.trendingUp,
                  color: savingsRate >= 20 ? AppColors.safe : AppColors.warning,
                ),
                const SizedBox(width: AppStyles.s),
                _buildStatWidget(
                  label: 'Debt Ratio (DTI)',
                  value: '${debtRatio.toStringAsFixed(0)}%',
                  icon: LucideIcons.percent,
                  color: debtRatio <= 30 ? AppColors.safe : AppColors.critical,
                ),
                const SizedBox(width: AppStyles.s),
                _buildStatWidget(
                  label: 'Buffer Dana Darurat',
                  value: '${emergencyMonths.toStringAsFixed(1)} Bln',
                  icon: LucideIcons.shieldCheck,
                  color: emergencyMonths >= 6 ? AppColors.safe : AppColors.vulnerable,
                ),
              ],
            ),
            const SizedBox(height: AppStyles.l),

            // List of sub indicators
            const Text(
              'Breakdown Indikator Kerentanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppStyles.s),
            
            IndicatorCard(
              title: '1. Kestabilan Pendapatan',
              score: score.incomeStabilityScore,
              icon: LucideIcons.briefcase,
              description: 'Tingkat kepastian pendapatan (Karyawan Tetap vs Wiraswasta/Tidak Tetap).',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Kestabilan Pendapatan',
                score: score.incomeStabilityScore,
                formula: 'Tipe Pekerjaan (Tetap = 100, Tidak Tetap = 60)',
                tip: 'Jika pendapatan tidak tetap, targetkan dana darurat 1.5x lebih besar untuk mengantisipasi bulan-bulan dengan pendapatan rendah.',
              ),
            ),
            const SizedBox(height: AppStyles.s),

            IndicatorCard(
              title: '2. Rasio Pengeluaran',
              score: score.expenseRatioScore,
              icon: LucideIcons.receipt,
              description: 'Persentase total pendapatan bulanan yang dihabiskan untuk kebutuhan.',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Rasio Pengeluaran',
                score: score.expenseRatioScore,
                formula: '(Total Pengeluaran / Pendapatan) x 100%',
                tip: 'Idealnya pengeluaran bulanan tidak melebihi 80% pendapatan. Sisihkan minimal 20% untuk tabungan dan dana darurat terlebih dahulu (Metode 50/30/20).',
              ),
            ),
            const SizedBox(height: AppStyles.s),

            IndicatorCard(
              title: '3. Kesiapan Dana Darurat',
              score: score.emergencyFundScore,
              icon: LucideIcons.shieldAlert,
              description: 'Jumlah tabungan likuid dibandingkan dengan rata-rata pengeluaran bulanan.',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Kesiapan Dana Darurat',
                score: score.emergencyFundScore,
                formula: 'Tabungan Likuid / Pengeluaran Bulanan',
                tip: 'Aman: memiliki tabungan darurat minimal 6 kali pengeluaran bulanan. Mulai menabung di rekening terpisah secara otomatis.',
              ),
            ),
            const SizedBox(height: AppStyles.s),

            IndicatorCard(
              title: '4. Rasio Beban Utang',
              score: score.debtBurdenScore,
              icon: LucideIcons.calendarClock,
              description: 'Besarnya cicilan bulanan yang harus dibayar terhadap pendapatan masuk.',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Rasio Beban Utang',
                score: score.debtBurdenScore,
                formula: '(Cicilan Bulanan / Pendapatan Bersih) x 100%',
                tip: 'Jaga cicilan bulanan maksimal 30% dari pendapatan. Hindari membuat utang konsumtif baru atau menggunakan limit Paylater.',
              ),
            ),
            const SizedBox(height: AppStyles.s),

            IndicatorCard(
              title: '5. Tanggungan Keluarga',
              score: score.dependentLoadScore,
              icon: LucideIcons.users,
              description: 'Beban tanggungan anggota keluarga non-produktif (anak, orang tua).',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Tanggungan Keluarga',
                score: score.dependentLoadScore,
                formula: 'Jumlah Tanggungan & Tipe Keluarga (Sandwich = penalti 15 poin)',
                tip: 'Generasi Sandwich memikul tanggungan ganda. Kunci mitigasinya adalah asuransi kesehatan aktif untuk orang tua agar tidak mengganggu keuangan Anda saat mereka sakit.',
              ),
            ),
            const SizedBox(height: AppStyles.s),

            IndicatorCard(
              title: '6. Kesiapan Proteksi',
              score: score.protectionReadinessScore,
              icon: LucideIcons.umbrella,
              description: 'Ketersediaan jaminan asuransi kesehatan (BPJS) dan jiwa.',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Kesiapan Proteksi',
                score: score.protectionReadinessScore,
                formula: 'BPJS Kesehatan aktif (80%) + Asuransi Jiwa aktif (20%)',
                tip: 'Asuransi kesehatan adalah wajib. Daftarkan BPJS Kesehatan kelas mandiri terkecil untuk semua anggota keluarga agar terhindar dari krisis biaya medis.',
              ),
            ),
            const SizedBox(height: AppStyles.s),

            IndicatorCard(
              title: '7. Daya Serap Guncangan',
              score: score.shockAbsorptionScore,
              icon: LucideIcons.heartPulse,
              description: 'Kekuatan gabungan finansial menahan guncangan krisis finansial mendadak.',
              onTap: () => _showIndicatorDetail(
                context: context,
                title: 'Daya Serap Guncangan',
                score: score.shockAbsorptionScore,
                formula: 'FVS Emergency + FVS Expense + FVS Debt (Penalti 50% jika defisit)',
                tip: 'Meningkatkan daya serap dilakukan dengan membesarkan dana darurat dan meminimalkan utang konsumtif sehingga pengeluaran dasar bernilai rendah.',
              ),
            ),
            const SizedBox(height: AppStyles.l),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard(FamilyFinanceProfile profile) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.4), AppColors.accent.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyles.radiusMedium,
        border: Border.all(color: AppColors.surfaceCard.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.users, color: AppColors.primaryLight, size: 28),
          const SizedBox(width: AppStyles.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keluarga Tangguh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pendapatan: ${_formatCurrency(profile.monthlyIncome)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatWidget({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppStyles.m, horizontal: AppStyles.s),
        decoration: AppStyles.cardDecoration,
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppStyles.s),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIndicatorDetail({
    required BuildContext context,
    required String title,
    required int score,
    required String formula,
    required String tip,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final color = AppColors.getScoreColor(score);
        final cat = AppColors.getScoreCategory(score);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppStyles.m, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: AppStyles.radiusCircular,
                      ),
                      child: Text(
                        '$score - $cat',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.surfaceCard, height: AppStyles.xl),
                
                // Formula description
                const Text(
                  'Dasar Perhitungan (Rule-Based):',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  formula,
                  style: const TextStyle(fontFamily: 'monospace', color: AppColors.primaryLight, fontSize: 13),
                ),
                const SizedBox(height: AppStyles.m),

                // Mitigation Tips
                const Text(
                  'Rekomendasi / Mitigasi Preventif:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
                ),
                const SizedBox(height: AppStyles.xl),

                // Close Button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Peringatan Dini Finansial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        for (var n in notifications) {
                          ref.read(notificationsProvider.notifier).markAsRead(n['notification_id']);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Tandai Semua Dibaca'),
                    )
                  ],
                ),
                const Divider(color: AppColors.surfaceCard),
                if (notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'Tidak ada peringatan terdeteksi.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final bool isRead = notif['is_read'] == 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isRead ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                            border: Border.all(
                              color: isRead ? AppColors.surfaceCard.withOpacity(0.5) : AppColors.critical.withOpacity(0.3),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning_amber_rounded,
                              color: isRead ? AppColors.textMuted : AppColors.critical,
                            ),
                            title: Text(
                              notif['message'],
                              style: TextStyle(
                                color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            trailing: !isRead
                                ? IconButton(
                                    icon: const Icon(Icons.done, color: AppColors.accent),
                                    onPressed: () {
                                      ref.read(notificationsProvider.notifier).markAsRead(notif['notification_id']);
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
