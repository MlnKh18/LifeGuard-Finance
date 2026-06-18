import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/savings_vault_entity.dart';
import '../bloc/vault_cubit.dart';
import '../bloc/vault_state.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class SavingsVaultPage extends StatelessWidget {
  const SavingsVaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VaultCubit>(
      create: (context) => getIt<VaultCubit>()..loadVaults(),
      child: const VaultView(),
    );
  }
}

class VaultView extends StatelessWidget {
  const VaultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pos Dana Darurat', style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) {
          if (state is VaultLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is VaultError) {
            return _buildErrorView(context, state.message);
          }

          if (state is VaultLoaded) {
            return _buildContent(context, state.vaults);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateVaultDialog(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SavingsVault> vaults) {
    final totalSaved = vaults.fold<double>(0, (sum, v) => sum + v.savedAmount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text('Total Dana Darurat', style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                _rupiahFormat.format(totalSaved),
                style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 32),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (vaults.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                const Icon(Icons.savings_outlined, size: 64, color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pos dana. Tambahkan pos dana darurat pertama Anda.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...vaults.map((vault) => _buildVaultCard(context, vault)),
      ],
    );
  }

  Widget _buildVaultCard(BuildContext context, SavingsVault vault) {
    final percent = (vault.progress * 100).round();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
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
                    Text(vault.name, style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      'Target: ${_rupiahFormat.format(vault.targetAmount)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 4,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.background),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: vault.progress,
                        strokeWidth: 4,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          vault.isCompleted ? AppColors.riskSafe : AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: AppTextStyles.dataLabel.copyWith(
                        color: vault.isCompleted ? AppColors.riskSafe : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Saved: ${_rupiahFormat.format(vault.savedAmount)}',
            style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: vault.isCompleted
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Completed'),
                    style: OutlinedButton.styleFrom(
                      disabledForegroundColor: AppColors.riskSafe,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () => _showAddFundsDialog(context, vault),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tabung'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateVaultDialog(BuildContext context) {
    final cubit = context.read<VaultCubit>();
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Pos Dana Baru'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Pos Dana'),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: targetController,
                  decoration: const InputDecoration(labelText: 'Target Dana (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    final amount = double.tryParse(val ?? '');
                    if (amount == null || amount <= 0) return 'Masukkan target yang valid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                cubit.createVault(
                  name: nameController.text.trim(),
                  targetAmount: double.parse(targetController.text),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFundsDialog(BuildContext context, SavingsVault vault) {
    final cubit = context.read<VaultCubit>();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Tabung ke ${vault.name}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              keyboardType: TextInputType.number,
              validator: (val) {
                final amount = double.tryParse(val ?? '');
                if (amount == null || amount <= 0) return 'Masukkan jumlah yang valid';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                cubit.addFunds(vault.id, double.parse(amountController.text));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tabung'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
