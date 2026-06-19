import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/savings_vault_entity.dart';
import '../../domain/entities/vault_transaction.dart';
import '../bloc/vault_cubit.dart';
import '../bloc/vault_state.dart';
import '../../../settings/presentation/widgets/profile_modals.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class VaultDetailPage extends StatelessWidget {
  final String vaultId;

  const VaultDetailPage({super.key, required this.vaultId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VaultCubit>.value(
      value: getIt<VaultCubit>()..loadVaultDetail(vaultId),
      child: const VaultDetailView(),
    );
  }
}

class VaultDetailView extends StatefulWidget {
  const VaultDetailView({super.key});

  @override
  State<VaultDetailView> createState() => _VaultDetailViewState();
}

class _VaultDetailViewState extends State<VaultDetailView> {
  @override
  void dispose() {
    getIt<VaultCubit>().loadVaults();
    super.dispose();
  }

  void _showAddDepositDialog(BuildContext context, SavingsVault vault) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<VaultCubit>(),
        child: AppFormBottomSheet(
          title: 'Tambah Setoran',
          child: AddVaultDepositForm(vault: vault, onSuccess: () {}),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<VaultCubit>().loadVaultDetail(vault.id);
      }
    });
  }

  void _showWithdrawDialog(BuildContext context, SavingsVault vault) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<VaultCubit>(),
        child: AppFormBottomSheet(
          title: 'Kurangi Saldo Tabungan',
          child: SubtractVaultBalanceForm(vault: vault, onSuccess: () {}),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<VaultCubit>().loadVaultDetail(vault.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail Tabungan', style: AppTextStyles.heading3),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<VaultCubit, VaultState>(
        listener: (context, state) {
          if (state is VaultActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.riskSafe),
            );
          } else if (state is VaultError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.riskCritical),
            );
          }
        },
        builder: (context, state) {
          if (state is VaultLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VaultDetailLoaded) {
            final vault = state.vault;
            final transactions = state.transactions;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderCard(vault),
                        const SizedBox(height: 16),
                        _buildProgressCard(vault),
                        const SizedBox(height: 16),
                        _buildTargetCard(vault),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddDepositDialog(context, vault),
                                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                label: const Text('Setor', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskSafe),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showWithdrawDialog(context, vault),
                                icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                                label: const Text('Tarik', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskCritical),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('Riwayat Transaksi', style: AppTextStyles.heading2),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildTransactionList(transactions),
              ],
            );
          }

          if (state is VaultError) {
            return Center(child: Text(state.message, style: AppTextStyles.bodyMedium));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeaderCard(SavingsVault vault) {
    final isFamily = vault.scope == SavingsVaultScope.family;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vault.name, style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(vault.savingPurpose ?? 'Tujuan tidak diisi', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isFamily ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFamily ? 'Keluarga' : 'Pribadi',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isFamily ? AppColors.primary : AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (!isFamily && vault.ownerEmail != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(vault.ownerEmail!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(SavingsVault vault) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Tabungan', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_rupiahFormat.format(vault.savedAmount), style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
              Text('${vault.progressPercentage.toStringAsFixed(1)}%', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: vault.progress,
            backgroundColor: AppColors.border,
            color: vault.isCompleted ? AppColors.riskSafe : AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              Text(_rupiahFormat.format(vault.targetAmount), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sisa', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              Text(_rupiahFormat.format(vault.remainingAmount), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(SavingsVault vault) {
    final freqStr = vault.savingFrequency == SavingFrequency.weekly 
        ? 'Mingguan' 
        : vault.savingFrequency == SavingFrequency.yearly ? 'Tahunan' : 'Bulanan';
    
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rencana Setoran', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          _buildInfoRow('Frekuensi', freqStr),
          const SizedBox(height: 12),
          _buildInfoRow('Target Setoran ($freqStr)', _rupiahFormat.format(vault.periodicTargetAmount ?? 0)),
          const SizedBox(height: 12),
          _buildInfoRow('Rekomendasi Setoran Saat Ini', _rupiahFormat.format(vault.recommendedContribution), highlight: true),
          if (vault.deadline != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Tenggat Waktu', DateFormat('dd MMM yyyy').format(vault.deadline!)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: Text('Belum ada riwayat setoran.', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = transactions[index] as VaultTransaction;
            final isDeposit = tx.type == VaultTransactionType.deposit;
            return AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isDeposit ? AppColors.riskSafe.withValues(alpha: 0.2) : AppColors.riskCritical.withValues(alpha: 0.2),
                    child: Icon(
                      isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isDeposit ? AppColors.riskSafe : AppColors.riskCritical,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isDeposit ? 'Setoran Masuk' : 'Saldo Ditarik', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        if (tx.note != null && tx.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(tx.note!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 4),
                        Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(
                    _rupiahFormat.format(tx.amount),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDeposit ? AppColors.riskSafe : AppColors.riskCritical,
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: transactions.length,
        ),
      ),
    );
  }
}
