import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final _targetController = TextEditingController();
  String _selectedGoalType = 'Emergency';

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

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
                borderRadius: AppStyles.radiusMedium,
                side: const BorderSide(color: AppColors.surfaceCard, width: 1),
              ),
              title: const Text(
                'Buat Kantong Tabungan',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedGoalType,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Jenis Tujuan',
                      prefixIcon: const Icon(LucideIcons.flag, color: AppColors.accent),
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
                  const SizedBox(height: AppStyles.m),
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Target Nominal (Rp)',
                      prefixIcon: const Icon(LucideIcons.coins, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusSmall),
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
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
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
            borderRadius: AppStyles.radiusMedium,
            side: const BorderSide(color: AppColors.surfaceCard, width: 1),
          ),
          title: Text(
            'Isi Saldo $goalName',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: AppStyles.inputDecoration(
              labelText: 'Jumlah Setoran (Rp)',
              prefixIcon: const Icon(LucideIcons.plusCircle, color: AppColors.accent),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusSmall),
              ),
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0.0;
                if (amt > 0) {
                  ref.read(vaultsProvider.notifier).addFunds(vaultId, amt);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Setoran ${_formatCurrency(amt)} berhasil ditambahkan!')),
                  );
                }
              },
              child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
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
        return LucideIcons.shieldAlert;
      case 'Education':
        return LucideIcons.graduationCap;
      case 'Health':
        return LucideIcons.heartPulse;
      case 'Retirement':
        return LucideIcons.piggyBank;
      default:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaults = ref.watch(vaultsProvider);
    final score = ref.watch(fvsStateProvider);

    String smartRoutingAdvice = 'Lengkapi profil keuangan terlebih dahulu untuk mengaktifkan Alokasi Dana Cerdas.';
    if (score != null) {
      final emergencyScore = score.emergencyFundScore;
      final debtScore = score.debtBurdenScore;
      final protectionScore = score.protectionReadinessScore;

      if (emergencyScore < 40) {
        smartRoutingAdvice = 'Alokasi Pendapatan: Prioritaskan 25% dari pendapatan bersih bulanan untuk membangun Dana Darurat Anda terlebih dahulu (Skor saat ini Kritis: $emergencyScore).';
      } else if (debtScore < 40) {
        smartRoutingAdvice = 'Alokasi Pendapatan: Alokasikan 20% pendapatan untuk percepatan pelunasan utang pokok/cicilan guna menurunkan rasio beban utang.';
      } else if (protectionScore < 40) {
        smartRoutingAdvice = 'Alokasi Pendapatan: Sisihkan 10% pendapatan untuk mengaktifkan BPJS Kesehatan atau asuransi jiwa dasar agar terlindung dari risiko guncangan medis.';
      } else {
        smartRoutingAdvice = 'Alokasi Pendapatan: Kondisi aman. Alokasikan 10% Dana Darurat, 15% Investasi Jangka Panjang, dan 10% Pendidikan Anak.';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantong Simpanan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppColors.accent),
            onPressed: _showAddVaultDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.radiusMedium,
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1.5),
                ),
                padding: const EdgeInsets.all(AppStyles.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.navigation, color: AppColors.accent, size: 24),
                        const SizedBox(width: AppStyles.s),
                        const Text(
                          'Alokasi Dana Cerdas',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.s),
                    Text(
                      smartRoutingAdvice,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.l),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kantong Tabungan Virtual',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddVaultDialog,
                    icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.accent),
                    label: const Text('Tambah', style: TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.s),
              if (vaults.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppStyles.xxl),
                    child: const Column(
                      children: [
                        Icon(LucideIcons.folderOpen, size: 48, color: AppColors.textMuted),
                        SizedBox(height: AppStyles.s),
                        Text(
                          'Belum ada kantong tabungan virtual.',
                          style: TextStyle(color: AppColors.textSecondary),
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
                      margin: const EdgeInsets.only(bottom: AppStyles.s),
                      decoration: AppStyles.cardDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(AppStyles.m),
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
                                    const SizedBox(width: AppStyles.s),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGoalLabel(type),
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Prioritas: ${vault['priority']}',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: AppColors.critical, size: 20),
                                  onPressed: () {
                                    ref.read(vaultsProvider.notifier).deleteVault(id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kantong tabungan dihapus.')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.m),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Progres Terkumpul',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                Text(
                                  '${(percent * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                color: AppColors.accent,
                                backgroundColor: AppColors.background,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: AppStyles.s),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatCurrency(current),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Target: ${_formatCurrency(target)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.s),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceCard,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppStyles.radiusSmall,
                                  ),
                                ),
                                onPressed: () => _showAddFundsDialog(id, _getGoalLabel(type)),
                                icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.textPrimary),
                                label: const Text(
                                  'Isi Setoran Tabungan',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                            ),
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
