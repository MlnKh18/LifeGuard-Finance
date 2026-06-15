import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pinEnabled = false;
  bool _notificationsEnabled = true;

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: AppColors.critical),
              SizedBox(width: AppStyles.s),
              Text('Hapus Seluruh Data?', style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
          content: const Text(
            'Tindakan ini akan menghapus permanen seluruh profil keuangan, riwayat FVS score, dan simulasi Anda dari perangkat ini. Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.critical,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                
                // Wipe DB and Reset Riverpod
                final resetFn = ref.read(databaseResetProvider);
                await resetFn();

                // Success Message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seluruh data finansial Anda telah berhasil dihapus.'),
                      backgroundColor: AppColors.critical,
                    ),
                  );
                }
              },
              child: const Text('Ya, Hapus Data'),
            ),
          ],
        );
      },
    );
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Disclaimer Edukatif', style: TextStyle(color: AppColors.textPrimary)),
          content: const SingleChildScrollView(
            child: Text(
              'Aplikasi LifeGuard Finance dirancang semata-mata untuk tujuan simulasi, penilaian mandiri (self-assessment), dan sarana edukasi literasi keuangan keluarga.\n\nSkor Financial Vulnerability Score (FVS) dihitung berdasarkan formula rule-based standar perencanaan keuangan dan tidak mewakili penilaian kelayakan kredit perbankan formal.\n\nAplikasi ini tidak memberikan saran investasi, asuransi, atau penasehat keuangan profesional bersertifikat yang mengikat. Silakan berkonsultasi dengan perencana keuangan berlisensi untuk pengambilan keputusan finansial penting.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Saya Mengerti'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppStyles.m),
        children: [
          // Section Profile
          const Text('PROFIL & KEUANGAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.0)),
          const SizedBox(height: AppStyles.s),
          Container(
            decoration: AppStyles.cardDecoration,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.userPlus, color: AppColors.primaryLight),
                  title: const Text('Edit Profil Finansial', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Perbarui pendapatan, utang, atau tanggungan keluarga', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
                  onTap: () {
                    // Navigate to onboarding screen to overwrite profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.l),

          // Section Security & Settings
          const Text('KEAMANAN & PREFERENSI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.0)),
          const SizedBox(height: AppStyles.s),
          Container(
            decoration: AppStyles.cardDecoration,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(LucideIcons.lock, color: AppColors.accent),
                  title: const Text('Aktifkan PIN Pengunci', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Minta PIN saat membuka aplikasi untuk keamanan data', style: TextStyle(fontSize: 12)),
                  value: _pinEnabled,
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      _pinEnabled = val;
                    });
                  },
                ),
                const Divider(color: AppColors.surfaceCard, height: 1),
                SwitchListTile(
                  secondary: const Icon(LucideIcons.bellRing, color: AppColors.accent),
                  title: const Text('Notifikasi Peringatan', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Dapatkan alarm bulanan untuk memperbarui profil', style: TextStyle(fontSize: 12)),
                  value: _notificationsEnabled,
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.l),

          // Section Privacy & Legal
          const Text('PRIVASI & LEGALITAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.0)),
          const SizedBox(height: AppStyles.s),
          Container(
            decoration: AppStyles.cardDecoration,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.info, color: AppColors.primaryLight),
                  title: const Text('Disclaimer Hukum', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Penafian edukasi aplikasi', style: TextStyle(fontSize: 12)),
                  onTap: _disclaimerDialog,
                ),
                const Divider(color: AppColors.surfaceCard, height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: AppColors.critical),
                  title: const Text('Hapus Seluruh Data Lokal', style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Wipe profile, riwayat FVS score, dan database', style: TextStyle(fontSize: 12)),
                  onTap: _showResetConfirmation,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.l),

          // Section Competition
          const Text('KOMPETISI & VERSI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.0)),
          const SizedBox(height: AppStyles.s),
          Container(
            padding: const EdgeInsets.all(AppStyles.m),
            decoration: AppStyles.cardDecoration,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LifeGuard Finance Mobile Prototype',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Konteks: Mobile App Design Competition RAKERNAS IndoCEISS 2026\nTema: Digital Innovation and Creative Intelligence for Sustainable Future\nVersi: 1.0.0 (MVP Local-First)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _disclaimerDialog() {
    _showDisclaimer();
  }
}
