import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final _targetController = TextEditingController();
  String _selectedGoalType = 'Emergency';

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _showAddVaultDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                side: BorderSide(color: AppColors.surfaceCard, width: 1),
              ),
              title: Text(
                'Buat Kantong Tabungan',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedGoalType,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Jenis Tujuan',
                      prefixIcon: const Icon(Icons.flag, color: AppColors.accent),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Emergency', child: Text('Dana Darurat')),
                      DropdownMenuItem(value: 'Education', child: Text('Pendidikan Anak')),
                      DropdownMenuItem(value: 'Health', child: Text('Kesehatan/Medis')),
                      DropdownMenuItem(value: 'Retirement', child: Text('Dana Pensiun')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          _selectedGoalType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Target Nominal (Rp)',
                      prefixIcon: const Icon(Icons.monetization_on, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                    ),
                  ),
                  onPressed: () {
                    final target = double.tryParse(_targetController.text) ?? 0.0;
                    if (target > 0) {
                      int priority = 1;
                      if (_selectedGoalType == 'Emergency') priority = 1;
                      if (_selectedGoalType == 'Health') priority = 2;
                      if (_selectedGoalType == 'Education') priority = 3;
                      if (_selectedGoalType == 'Retirement') priority = 4;

                      ref.read(vaultsProvider.notifier).addVault(
                            _selectedGoalType,
                            target,
                            0.0,
                            priority,
                          );
                      _targetController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kantong tabungan berhasil dibuat!')),
                      );
                    }
                  },
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddFundsDialog(String vaultId, String goalName) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            side: BorderSide(color: AppColors.surfaceCard, width: 1),
          ),
          title: Text(
            'Isi Saldo $goalName',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: AppStyles.inputDecoration(
              labelText: 'Jumlah Setoran (Rp)',
              prefixIcon: const Icon(Icons.add_circle, color: AppColors.accent),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
              ),
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0.0;
                if (amt > 0) {
                  ref.read(vaultsProvider.notifier).addFunds(vaultId, amt);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Setoran Rp ${amt.toStringAsFixed(0)} berhasil ditambahkan!')),
                  );
                }
              },
              child: Text(
                'Tambah',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getGoalLabel(String type) {
    switch (type) {
      case 'Emergency':
        return 'Dana Darurat';
      case 'Education':
        return 'Pendidikan Anak';
      case 'Health':
        return 'Kesehatan & Proteksi';
      case 'Retirement':
        return 'Dana Pensiun';
      default:
        return type;
    }
  }

  IconData _getGoalIcon(String type) {
    switch (type) {
      case 'Emergency':
        return Icons.emergency;
      case 'Education':
        return Icons.school;
      case 'Health':
        return Icons.local_hospital;
      case 'Retirement':
        return Icons.elderly;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaults = ref.watch(vaultsProvider);
    final score = ref.watch(fvsStateProvider);

    // Goal-Driven Smart Routing Logic
    String smartRoutingAdvice = 'Lengkapi profil keuangan terlebih dahulu untuk mengaktifkan Smart Routing.';
    if (score != null) {
      final emergencyScore = score.emergencyFundScore;
      final debtScore = score.debtBurdenScore;
      final protectionScore = score.protectionReadinessScore;

      if (emergencyScore < 40) {
        smartRoutingAdvice = 'Alokasi Pendapatan: Prioritaskan 25% dari pendapatan bersih bulanan untuk membangun Dana Darurat Anda terlebih dahulu (Skor saat ini Kritis: $emergencyScore).';
      } else if (debtScore < 40) {
        smartRoutingAdvice = 'Alokasi Pendapatan: Alokasikan 20% pendapatan untuk percepatan pelunasan utang pokok/cicilan guna menurunkan Debt Burden Ratio.';
      } else if (protectionScore < 40) {
        smartRoutingAdvice = 'Alokasi Pendapatan: Sisihkan 10% pendapatan untuk mengaktifkan BPJS Kesehatan atau asuransi jiwa dasar agar terlindung dari risiko guncangan medis.';
      } else {
        smartRoutingAdvice = 'Alokasi Pendapatan: Kondisi aman. Alokasikan 10% Dana Darurat, 15% Investasi Jangka Panjang, dan 10% Pendidikan Anak.';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Savings Vault',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
            onPressed: _showAddVaultDialog,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smart Routing Panel
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  border: BorderSide(color: AppColors.primaryLight.withOpacity(0.5), width: 1.5),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route, color: AppColors.accent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Goal-Driven Smart Routing',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      smartRoutingAdvice,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kantong Tabungan Virtual',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddVaultDialog,
                    icon: const Icon(Icons.add, size: 16, color: AppColors.accent),
                    label: Text(
                      'Tambah',
                      style: GoogleFonts.outfit(color: AppColors.accent),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (vaults.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.folder_open, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada kantong tabungan virtual.',
                          style: GoogleFonts.outfit(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vaults.length,
                  itemBuilder: (context, index) {
                    final vault = vaults[index];
                    final String id = vault['vault_id'];
                    final String type = vault['goal_type'];
                    final double target = (vault['target_amount'] as num).toDouble();
                    final double current = (vault['current_amount'] as num).toDouble();
                    final double percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: AppStyles.cardDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.accent.withOpacity(0.1),
                                      child: Icon(_getGoalIcon(type), color: AppColors.accent),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGoalLabel(type),
                                          style: GoogleFonts.outfit(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Prioritas: ${vault['priority']}',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.critical, size: 20),
                                  onPressed: () {
                                    ref.read(vaultsProvider.notifier).deleteVault(id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kantong tabungan dihapus.')),
                                    );
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progres Terkumpul',
                                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                Text(
                                  '${(percent * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.inter(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                color: AppColors.accent,
                                backgroundColor: AppColors.background,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp ${current.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Target: Rp ${target.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceCard,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                                  ),
                                ),
                                onPressed: () => _showAddFundsDialog(id, _getGoalLabel(type)),
                                icon: const Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                                label: Text(
                                  'Isi Setoran Tabungan',
                                  style: GoogleFonts.outfit(color: AppColors.textPrimary),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
