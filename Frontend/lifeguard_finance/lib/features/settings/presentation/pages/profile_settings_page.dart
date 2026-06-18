import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../savings_vault/presentation/bloc/vault_cubit.dart';
import '../../../savings_vault/domain/entities/savings_vault_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_modals.dart';
import '../../domain/entities/profile_summary.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  String formatRupiah(double amount) {
    try {
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
    } catch (_) {
      return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('================ PROFILE PAGE OPENED ================');
    // Shared root AuthBloc is used for logout / auth checks
    final authBloc = context.read<AuthBloc>();

    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(LoadProfileSummary()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Profil & Pengaturan', style: AppTextStyles.heading2),
          centerTitle: false,
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileClearSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Seluruh data lokal berhasil dihapus.'),
                  backgroundColor: AppColors.riskSafe,
                ),
              );
              authBloc.add(LogoutRequested());
              context.go('/onboarding');
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terjadi kesalahan: ${state.message}'),
                  backgroundColor: AppColors.riskCritical,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is ProfileLoaded) {
              final summary = state.summary;
              final isHead = summary.role == UserRole.headOfFamily;

              debugPrint('================ PROFILE LOADED STATE ================');
              debugPrint('Profile userName: ${summary.userName}');
              debugPrint('Profile email: ${summary.email}');
              debugPrint('Profile role: ${summary.role.name}');
              debugPrint('Profile familyCode: ${summary.familyCode}');
              debugPrint('Profile visibleVaults count: ${summary.visibleVaults.length}');
              debugPrint('Profile familyVaults count: ${summary.familyVaults.length}');
              debugPrint('Profile personalVaults count: ${summary.personalVaults.length}');

              for (final vault in summary.visibleVaults) {
                debugPrint(
                  'PROFILE VAULT => '
                  'id=${vault.id}, '
                  'name=${vault.name}, '
                  'scope=${vault.scope.name}, '
                  'familyId=${vault.familyId}, '
                  'ownerUserId=${vault.ownerUserId}, '
                  'ownerEmail=${vault.ownerEmail}, '
                  'currentAmount=${vault.savedAmount}, '
                  'targetAmount=${vault.targetAmount}',
                );
              }

              if (summary.allVaults.isNotEmpty && summary.visibleVaults.isEmpty) {
                debugPrint('WARNING: Vault data exists but no visible vault after filtering.');
                debugPrint('Possible mismatch: familyId/currentFamilyId or ownerUserId/currentUserId.');
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(LoadProfileSummary());
                },
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // A. Header Profile Card
                    _buildHeaderCard(context, summary),
                    const SizedBox(height: 16),

                    // B. Financial Summary Section
                    _buildFinancialSection(context, summary, isHead),
                    const SizedBox(height: 16),

                    // C. FVS Status Section
                    _buildFvsSection(context, summary, isHead),
                    const SizedBox(height: 16),

                    // D. Savings Vault List Section
                    _buildVaultSection(context, summary, isHead),
                    const SizedBox(height: 16),

                    // E. Literacy Progress Section
                    _buildLiteracySection(context, summary),
                    const SizedBox(height: 16),

                    // F. Community Section (Head only)
                    if (summary.canAccessCommunity) ...[
                      _buildCommunitySection(context, summary),
                      const SizedBox(height: 16),
                    ],

                    // G. Family Members List (Head only)
                    if (summary.canManageFamilyMembers) ...[
                      _buildFamilyMembersSection(context, summary),
                      const SizedBox(height: 16),
                    ],

                    // H. Reward History Section
                    _buildRewardSection(context, summary),
                    const SizedBox(height: 24),

                    // I. Privacy & Settings List
                    Text('Pengaturan & Tindakan', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    _buildSettingsList(context, summary, isHead, authBloc),
                    const SizedBox(height: 48),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.riskCritical),
                    const SizedBox(height: 16),
                    const Text('Gagal memuat profil.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(LoadProfileSummary());
                      },
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ProfileSummary summary) {
    final initials = summary.userName.isNotEmpty ? summary.userName[0].toUpperCase() : '?';
    final isHead = summary.role == UserRole.headOfFamily;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: isHead ? AppColors.primary : AppColors.secondary.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: AppTextStyles.heading1.copyWith(color: isHead ? Colors.white : AppColors.secondary, fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary.userName, style: AppTextStyles.heading2),
                      Text(summary.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHead ? AppColors.primary.withValues(alpha: 0.1) : AppColors.textSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isHead ? 'Kepala Keluarga' : 'Anggota Keluarga',
                          style: AppTextStyles.dataLabel.copyWith(
                            color: isHead ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keluarga', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    Text(summary.familyName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                if (summary.familyCode.isNotEmpty && summary.familyCode != '-')
                  Row(
                    children: [
                      Text(
                        summary.familyCode,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: summary.familyCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kode keluarga disalin ke clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    Text('${summary.totalRewardPoints} pts', style: AppTextStyles.heading3.copyWith(color: Colors.orange)),
                  ],
                ),
                Text(
                  summary.activeBadge,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection(BuildContext context, ProfileSummary summary, bool isHead) {
    if (summary.familyProfile == null) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.border),
              const SizedBox(height: 12),
              Text(
                'Profil keuangan keluarga belum lengkap.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (isHead) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Lengkapi Profil Keuangan',
                  onPressed: () => context.push('/family-profile'),
                ),
              ]
            ],
          ),
        ),
      );
    }

    final fp = summary.familyProfile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Profil Keuangan',
          trailing: isHead
              ? TextButton(
                  onPressed: () => context.push('/family-profile'),
                  child: const Text('Edit'),
                )
              : null,
        ),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFinanceRow('Pendapatan Tetap', formatRupiah(fp.fixedIncome)),
                _buildFinanceRow('Pendapatan Tidak Tetap', formatRupiah(fp.variableIncome)),
                _buildFinanceRow('Total Pendapatan Bulanan', formatRupiah(summary.totalIncome), isTotal: true),
                _buildFinanceRow('Pengeluaran Rutin', formatRupiah(fp.routineExpenses)),
                _buildFinanceRow('Cicilan Bulanan', formatRupiah(fp.debtPayments)),
                _buildFinanceRow('Dana Darurat / Likuid', formatRupiah(fp.liquidSavings)),
                _buildFinanceRow('Tanggungan', '${fp.totalDependents} orang'),
                _buildFinanceRow('Status BPJS', fp.hasBpjs ? 'Aktif' : 'Tidak Aktif', color: fp.hasBpjs ? AppColors.riskSafe : AppColors.riskCritical),
                _buildFinanceRow('Asuransi Tambahan', fp.hasAdditionalInsurance ? 'Aktif' : 'Tidak Aktif', color: fp.hasAdditionalInsurance ? AppColors.riskSafe : AppColors.riskCritical),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFvsSection(BuildContext context, ProfileSummary summary, bool isHead) {
    if (summary.latestFvsScore < 0) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.shield_outlined, size: 48, color: AppColors.border),
              const SizedBox(height: 12),
              Text(
                isHead
                    ? 'Skor FVS belum dihitung.'
                    : 'Skor FVS akan tersedia setelah Kepala Keluarga melengkapi data.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (isHead) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Hitung Skor FVS',
                  onPressed: () => context.push('/dashboard'),
                ),
              ]
            ],
          ),
        ),
      );
    }

    Color badgeColor = AppColors.riskSafe;
    final cat = summary.latestFvsCategory.toLowerCase();
    if (cat.contains('waspada')) {
      badgeColor = AppColors.riskWarning;
    } else if (cat.contains('rentan')) {
      badgeColor = AppColors.riskWarning;
    } else if (cat.contains('kritis')) {
      badgeColor = AppColors.riskCritical;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Status Kerentanan Keuangan (FVS)'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Skor FVS: ${summary.latestFvsScore.toStringAsFixed(0)}/100',
                      style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        summary.latestFvsCategory,
                        style: AppTextStyles.dataLabel.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (summary.weakestIndicators.isNotEmpty) ...[
                  Text(
                    'Indikator Perlu Perbaikan:',
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...summary.weakestIndicators.map((ind) => Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 2),
                        child: Text('• $ind', style: AppTextStyles.bodySmall.copyWith(color: AppColors.riskCritical)),
                      )),
                ],
                const SizedBox(height: 12),
                Text(
                  'Dihitung pada: ${formatDate(summary.latestFvsCalculatedAt)}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Lihat Dashboard FVS'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVaultSection(BuildContext context, ProfileSummary summary, bool isHead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVaultList(
          context: context,
          title: 'Tabungan Keluarga',
          vaults: summary.familyVaults,
          totalTarget: summary.totalFamilyVaultTarget,
          totalSaved: summary.totalFamilyVaultSaved,
          isHead: isHead,
          canAdd: isHead,
          emptyMessage: 'Belum ada target tabungan keluarga.',
          badgeLabel: 'Dapat dipantau oleh anggota keluarga',
        ),
        const SizedBox(height: 24),
        _buildVaultList(
          context: context,
          title: 'Tabungan Pribadi Saya',
          vaults: summary.personalVaults,
          totalTarget: summary.totalPersonalVaultTarget,
          totalSaved: summary.totalPersonalVaultSaved,
          isHead: isHead,
          canAdd: true,
          emptyMessage: 'Belum ada target tabungan pribadi.',
          badgeLabel: 'Hanya terlihat oleh akun ini',
        ),
      ],
    );
  }

  Widget _buildVaultList({
    required BuildContext context,
    required String title,
    required List<SavingsVault> vaults,
    required double totalTarget,
    required double totalSaved,
    required bool isHead,
    required bool canAdd,
    required String emptyMessage,
    required String badgeLabel,
  }) {
    final displayed = vaults.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          trailing: canAdd
              ? Row(
                  children: [
                    if (vaults.length > 3)
                      TextButton(
                        onPressed: () => context.push('/savings-vault'),
                        child: const Text('Lihat Semua'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) {
                            return AppFormBottomSheet(
                              title: 'Tambah Pos Dana',
                              description: 'Buat pos alokasi dana darurat baru.',
                              child: BlocProvider<VaultCubit>.value(
                                value: getIt<VaultCubit>(),
                                child: BlocProvider<AuthBloc>.value(
                                  value: context.read<AuthBloc>(),
                                  child: AddVaultForm(onSuccess: () {
                                    context.read<ProfileBloc>().add(LoadProfileSummary());
                                  }),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            badgeLabel,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ),
        if (vaults.isNotEmpty) ...[
          AppCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Target:', style: AppTextStyles.bodySmall),
                      Text(formatRupiah(totalTarget), style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Terkumpul:', style: AppTextStyles.bodySmall),
                      Text(formatRupiah(totalSaved), style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        if (vaults.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.savings_outlined, size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...displayed.map((vault) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vault.name,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(vault.progress * 100).toStringAsFixed(0)}%',
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      if (vault.scope == SavingsVaultScope.personal && vault.ownerEmail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          vault.ownerEmail!,
                          style: AppTextStyles.dataLabel.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: vault.progress,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          vault.isCompleted ? AppColors.riskSafe : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatRupiah(vault.savedAmount)} / ${formatRupiah(vault.targetAmount)}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (sheetContext) {
                                      return AppFormBottomSheet(
                                        title: 'Kurangi Saldo Tabungan',
                                        description: 'Gunakan fitur ini jika ada dana yang diambil dari tabungan.',
                                        child: BlocProvider<VaultCubit>.value(
                                          value: getIt<VaultCubit>(),
                                          child: SubtractVaultBalanceForm(
                                            vault: vault,
                                            onSuccess: () {
                                              context.read<ProfileBloc>().add(LoadProfileSummary());
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text('Kurangi', style: TextStyle(color: AppColors.riskCritical)),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (sheetContext) {
                                      return AppFormBottomSheet(
                                        title: 'Tambah Setoran',
                                        description: 'Masukkan nominal uang yang ingin ditambahkan ke tabungan ini.',
                                        child: BlocProvider<VaultCubit>.value(
                                          value: getIt<VaultCubit>(),
                                          child: AddVaultDepositForm(
                                            vault: vault,
                                            onSuccess: () {
                                              context.read<ProfileBloc>().add(LoadProfileSummary());
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text('Tambah'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildLiteracySection(BuildContext context, ProfileSummary summary) {
    final total = summary.literacyProgress.isNotEmpty ? summary.literacyProgress[1] as int : 5;
    final read = summary.literacyProgress.isNotEmpty ? summary.literacyProgress[0] as int : 0;
    final percent = total > 0 ? (read / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Perkembangan Literasi',
          trailing: TextButton(
            onPressed: () => context.push('/literacy'),
            child: const Text('Mulai Belajar'),
          ),
        ),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Modul Dibaca ($read/$total)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text('${(percent * 100).toStringAsFixed(0)}%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text('Rekomendasi Edukasi Keuangan:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...summary.recommendedLiteracyModules.take(2).map((mod) => InkWell(
                      onTap: () {
                        if (mod.externalUrl != null && mod.externalUrl!.isNotEmpty) {
                          UrlLauncherHelper.openExternalUrl(mod.externalUrl!);
                        } else {
                          context.push('/literacy/${mod.moduleId}');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mod.title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                  Text(mod.relatedIndicator, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context, ProfileSummary summary) {
    final posts = summary.communityPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Aktivitas Komunitas',
          trailing: TextButton(
            onPressed: () => context.push('/community'),
            child: const Text('Buka Feed'),
          ),
        ),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountCol('Posting Saya', posts.length),
                    _buildCountCol('Komentar Saya', summary.communityComments.length),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),
                if (posts.isEmpty)
                  Text(
                    'Belum ada aktivitas komunitas.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  )
                else ...[
                  Text('Posting Terbaru:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  AppCard(
                    color: AppColors.background,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(posts.first.tag, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            posts.first.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountCol(String title, int count) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('$count', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildFamilyMembersSection(BuildContext context, ProfileSummary summary) {
    final members = summary.familyMembers;
    final invites = summary.familyInvitations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Anggota Keluarga',
          trailing: Row(
            children: [
              TextButton(
                onPressed: () => context.push('/family-members'),
                child: const Text('Kelola'),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt, color: AppColors.primary),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) {
                      return AppFormBottomSheet(
                        title: 'Undang Anggota',
                        description: 'Undang anggota keluarga baru untuk bergabung.',
                        child: InviteMemberForm(onSuccess: () {
                          context.read<ProfileBloc>().add(LoadProfileSummary());
                        }),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (members.isNotEmpty) ...[
                  Text('Anggota Aktif:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...members.take(3).map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m.fullName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                            Text(m.relation, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      )),
                ],
                if (invites.isNotEmpty) ...[
                  const Divider(height: 20, color: AppColors.border),
                  Text('Undangan Pending:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...invites.take(3).map((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(i.invitedEmail, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                Text(i.inviteCode, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontSize: 10)),
                              ],
                            ),
                            Text(i.relation, style: AppTextStyles.bodySmall.copyWith(color: Colors.orange)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardSection(BuildContext context, ProfileSummary summary) {
    final list = summary.rewardTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Riwayat Poin & Hadiah',
          trailing: TextButton(
            onPressed: () => context.push('/reward'),
            child: const Text('Buka Toko'),
          ),
        ),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (list.isEmpty)
                  Text(
                    'Belum ada transaksi reward.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  )
                else
                  ...list.take(3).map((t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t['type'] as String, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                  Text(formatDate(t['date'] as DateTime), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                                ],
                              ),
                            ),
                            Text(
                              '+${t['points']} pts',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context, ProfileSummary summary, bool isHead, AuthBloc authBloc) {
    return AppCard(
      child: Column(
        children: [
          if (isHead) ...[
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
              title: const Text('Edit Profil Keuangan Keluarga'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.border),
              onTap: () => context.push('/family-profile'),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.primary),
              title: const Text('Kelola Anggota Keluarga'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.border),
              onTap: () => context.push('/family-members'),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          ListTile(
            leading: const Icon(Icons.security, color: AppColors.primary),
            title: const Text('Data & Privasi'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.border),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (sheetContext) {
                  return const AppFormBottomSheet(
                    title: 'Privasi',
                    child: DataPrivacyModal(),
                  );
                },
              );
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('Tentang LifeGuard Finance'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.border),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (sheetContext) {
                  return const AppFormBottomSheet(
                    title: 'Tentang Aplikasi',
                    child: AboutModal(),
                  );
                },
              );
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.riskWarning),
            title: const Text('Logout Sesi'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.border),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AppConfirmationDialog(
                    title: 'Logout',
                    message: 'Apakah Anda yakin ingin keluar dari sesi ini? Data keluarga Anda akan tetap tersimpan aman.',
                    confirmText: 'Keluar',
                    confirmColor: AppColors.riskWarning,
                    onConfirm: () {
                      authBloc.add(LogoutRequested());
                      context.go('/login');
                    },
                  );
                },
              );
            },
          ),
          if (isHead) ...[
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.riskCritical),
              title: const Text('Hapus Seluruh Data Lokal'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.border),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AppConfirmationDialog(
                      title: 'HAPUS DATA LOKAL',
                      message: 'PERINGATAN BAHAYA: Tindakan ini akan menghapus seluruh data lokal Anda (akun, profil keluarga, transaksi, simpanan). Tindakan ini tidak bisa dibatalkan!',
                      confirmText: 'HAPUS PERMANEN',
                      confirmColor: AppColors.riskCritical,
                      onConfirm: () {
                        context.read<ProfileBloc>().add(ClearProfileLocalData());
                      },
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
