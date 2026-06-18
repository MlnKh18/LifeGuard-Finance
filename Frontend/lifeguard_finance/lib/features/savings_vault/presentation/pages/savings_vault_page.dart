import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/savings_vault_entity.dart';
import '../../core/vault_permission_helper.dart';
import '../bloc/vault_cubit.dart';
import '../bloc/vault_state.dart';
import '../../../settings/presentation/widgets/profile_modals.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

const Map<String, IconData> _vaultIcons = {
  'savings': Icons.savings_rounded,
  'home': Icons.home_rounded,
  'school': Icons.school_rounded,
  'medical': Icons.local_hospital_rounded,
  'travel': Icons.flight_takeoff_rounded,
  'car': Icons.directions_car_rounded,
  'wedding': Icons.favorite_rounded,
  'gift': Icons.card_giftcard_rounded,
  'emergency': Icons.health_and_safety_rounded,
  'other': Icons.category_rounded,
};

IconData _iconForVault(SavingsVault vault) => _vaultIcons[vault.iconName] ?? Icons.savings_rounded;

Color _colorForPriority(VaultPriority priority) {
  switch (priority) {
    case VaultPriority.high:
      return AppColors.riskCritical;
    case VaultPriority.medium:
      return AppColors.riskWarning;
    case VaultPriority.low:
      return AppColors.riskSafe;
  }
}

String _labelForPriority(VaultPriority priority) {
  switch (priority) {
    case VaultPriority.high:
      return 'Tinggi';
    case VaultPriority.medium:
      return 'Sedang';
    case VaultPriority.low:
      return 'Rendah';
  }
}

class SavingsVaultPage extends StatelessWidget {
  const SavingsVaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VaultCubit>.value(
      value: getIt<VaultCubit>()..loadVaults(),
      child: const VaultView(),
    );
  }
}

class VaultView extends StatefulWidget {
  const VaultView({super.key});

  @override
  State<VaultView> createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView> {
  int _selectedTabIndex = 0; // 0: Semua, 1: Keluarga, 2: Pribadi

  void _showCreateVaultDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<VaultCubit>(),
        child: BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: AppFormBottomSheet(
            title: 'Tambah Pos Dana',
            child: AddVaultForm(
              onSuccess: () {},
            ),
          ),
        ),
      ),
    );
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
          description: 'Masukkan nominal uang yang ingin ditambahkan ke tabungan ini.',
          child: AddVaultDepositForm(
            vault: vault,
            onSuccess: () {},
          ),
        ),
      ),
    );
  }

  void _showSubtractBalanceDialog(BuildContext context, SavingsVault vault) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<VaultCubit>(),
        child: AppFormBottomSheet(
          title: 'Kurangi Saldo Tabungan',
          description: 'Gunakan fitur ini jika ada dana yang diambil dari tabungan.',
          child: SubtractVaultBalanceForm(
            vault: vault,
            onSuccess: () {},
          ),
        ),
      ),
    );
  }

  void _showVaultHistoryDialog(BuildContext context, SavingsVault vault) {
    context.read<VaultCubit>().loadTransactions(vault.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<VaultCubit>(),
        child: AppFormBottomSheet(
          title: 'Riwayat Transaksi',
          description: 'Riwayat setoran dan penarikan untuk ${vault.name}.',
          child: BlocBuilder<VaultCubit, VaultState>(
            buildWhen: (previous, current) => current is VaultTransactionsLoaded,
            builder: (context, state) {
              if (state is VaultTransactionsLoaded) {
                if (state.transactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('Belum ada riwayat transaksi.')),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final tx = state.transactions[index];
                    final isDeposit = tx.type.name == 'deposit';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isDeposit ? AppColors.riskSafe.withValues(alpha: 0.2) : AppColors.riskCritical.withValues(alpha: 0.2),
                        child: Icon(
                          isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isDeposit ? AppColors.riskSafe : AppColors.riskCritical,
                        ),
                      ),
                      title: Text(isDeposit ? 'Setoran Masuk' : 'Saldo Dikurangi', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.userEmail, style: AppTextStyles.dataLabel),
                          if (tx.note != null && tx.note!.isNotEmpty)
                            Text('Catatan: ${tx.note}', style: AppTextStyles.dataLabel.copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isDeposit ? "+" : "-"}${_rupiahFormat.format(tx.amount)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDeposit ? AppColors.riskSafe : AppColors.riskCritical,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yy, HH:mm').format(tx.createdAt),
                            style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VaultCubit, VaultState>(
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
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pos Dana Darurat', style: AppTextStyles.heading3),
        ),
        body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String currentUserId = '';
                String currentFamilyId = '';
                if (authState is AuthAuthenticated) {
                  currentUserId = authState.user.userId;
                  currentFamilyId = authState.user.familyId;
                }

                return BlocBuilder<VaultCubit, VaultState>(
                  builder: (context, vaultState) {
                    if (vaultState is VaultLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    if (vaultState is VaultError) {
                      return _buildErrorView(context, vaultState.message);
                    }

                    if (vaultState is VaultLoaded) {
                      debugPrint('================ SAVINGS VAULT PAGE LOADED ================');
                      debugPrint('SAVINGS PAGE vault count: ${vaultState.vaults.length}');
                      for (final vault in vaultState.vaults) {
                        debugPrint(
                          'SAVINGS PAGE VAULT => '
                          'id=${vault.id}, '
                          'name=${vault.name}, '
                          'scope=${vault.scope.name}, '
                          'familyId=${vault.familyId}, '
                          'ownerUserId=${vault.ownerUserId}, '
                          'ownerEmail=${vault.ownerEmail}',
                        );
                      }

                      final vaults = vaultState.vaults.where((v) {
                        final canView = VaultPermissionHelper.canViewVault(
                          vault: v,
                          currentUserId: currentUserId,
                          currentFamilyId: currentFamilyId,
                        );
                        if (!canView) return false;

                        if (_selectedTabIndex == 1) return v.scope == SavingsVaultScope.family;
                        if (_selectedTabIndex == 2) return v.scope == SavingsVaultScope.personal;
                        return true;
                      }).toList();

                      return _buildContent(context, vaults);
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () => _showCreateVaultDialog(context),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab(0, 'Semua'),
          const SizedBox(width: 8),
          _buildTab(1, 'Keluarga'),
          const SizedBox(width: 8),
          _buildTab(2, 'Pribadi'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.dataLabel.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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
                  _selectedTabIndex == 1
                      ? 'Belum ada tabungan keluarga.'
                      : _selectedTabIndex == 2
                          ? 'Belum ada tabungan pribadi.'
                          : 'Belum ada tabungan yang bisa dipantau.',
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
    final isFamily = vault.scope == SavingsVaultScope.family;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 12.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFamily ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFamily ? 'Tabungan Keluarga' : 'Tabungan Pribadi',
                  style: AppTextStyles.dataLabel.copyWith(
                    color: isFamily ? AppColors.primary : AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  if (!isFamily && vault.ownerEmail != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        vault.ownerEmail!,
                        style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: _colorForPriority(vault.priority), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _labelForPriority(vault.priority),
                    style: AppTextStyles.dataLabel.copyWith(color: _colorForPriority(vault.priority), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 10, top: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForVault(vault), color: AppColors.primary, size: 18),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vault.name, style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      'Keperluan: ${vault.savingPurpose ?? "Tidak disebutkan"}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${_rupiahFormat.format(vault.targetAmount)}',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.surfaceContainerHigh),
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
            'Terkumpul: ${_rupiahFormat.format(vault.savedAmount)}',
            style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
          ),
          if (vault.remainingAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Sisa Target: ${_rupiahFormat.format(vault.remainingAmount)}',
              style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (vault.deadline != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tenggat: ${DateFormat('dd MMM yyyy').format(vault.deadline!)}',
              style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (vault.recommendedContribution > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Rekomendasi Setoran: ${_rupiahFormat.format(vault.recommendedContribution)} / ${vault.savingFrequency == SavingFrequency.weekly ? 'minggu' : vault.savingFrequency == SavingFrequency.monthly ? 'bulan' : 'tahun'}',
              style: AppTextStyles.dataLabel.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: vault.isCompleted
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Selesai'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.riskSafe,
                          side: const BorderSide(color: AppColors.riskSafe),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _showAddDepositDialog(context, vault),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'history') _showVaultHistoryDialog(context, vault);
                  if (value == 'subtract') _showSubtractBalanceDialog(context, vault);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'history',
                    child: ListTile(leading: Icon(Icons.history), title: Text('Riwayat'), contentPadding: EdgeInsets.zero),
                  ),
                  const PopupMenuItem(
                    value: 'subtract',
                    child: ListTile(leading: Icon(Icons.remove), title: Text('Kurangi'), contentPadding: EdgeInsets.zero),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.riskCritical),
            const SizedBox(height: 16),
            Text('Gagal Memuat Data', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<VaultCubit>().loadVaults(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
