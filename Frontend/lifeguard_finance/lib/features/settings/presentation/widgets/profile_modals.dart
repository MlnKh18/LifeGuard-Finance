import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../savings_vault/presentation/bloc/vault_cubit.dart';
import '../../../savings_vault/domain/entities/savings_vault_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_role.dart';
class AppFormBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const AppFormBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(title, style: AppTextStyles.heading2),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Batal',
    this.confirmColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      title: Text(title, style: AppTextStyles.heading3),
      content: Text(message, style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText, style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(confirmText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class AddVaultForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddVaultForm({super.key, required this.onSuccess});

  @override
  State<AddVaultForm> createState() => _AddVaultFormState();
}

class _AddVaultFormState extends State<AddVaultForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _targetController = TextEditingController();
  final _initialController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _periodicTargetController = TextEditingController();
  DateTime? _selectedDeadline;
  SavingFrequency _frequency = SavingFrequency.monthly;
  SavingsVaultScope _scope = SavingsVaultScope.personal;
  VaultPriority _priority = VaultPriority.medium;
  String _iconName = _vaultIconChoices.first.key;

  bool _loading = false;

  static const List<MapEntry<String, IconData>> _vaultIconChoices = [
    MapEntry('savings', Icons.savings_rounded),
    MapEntry('home', Icons.home_rounded),
    MapEntry('school', Icons.school_rounded),
    MapEntry('medical', Icons.local_hospital_rounded),
    MapEntry('travel', Icons.flight_takeoff_rounded),
    MapEntry('car', Icons.directions_car_rounded),
    MapEntry('wedding', Icons.favorite_rounded),
    MapEntry('gift', Icons.card_giftcard_rounded),
    MapEntry('emergency', Icons.health_and_safety_rounded),
    MapEntry('other', Icons.category_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.role == UserRole.headOfFamily) {
        _scope = SavingsVaultScope.family;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _targetController.dispose();
    _initialController.dispose();
    _deadlineController.dispose();
    _periodicTargetController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final target = double.parse(_targetController.text);
        final initial = double.tryParse(_initialController.text) ?? 0.0;
        final periodicTarget = double.tryParse(_periodicTargetController.text);
        final name = _nameController.text.trim();
        final category = _categoryController.text.trim();

        final fullName = category.isNotEmpty ? '$name ($category)' : name;

        final authState = context.read<AuthBloc>().state;
        String? familyId;
        String? ownerUserId;
        String? ownerEmail;
        String? ownerName;

        if (authState is AuthAuthenticated) {
          familyId = authState.user.familyId;
          ownerUserId = authState.user.userId;
          ownerEmail = authState.user.email;
          ownerName = authState.user.fullName;
        }

        debugPrint('================ ADD VAULT SUBMIT ================');
        debugPrint('ADD VAULT name: $fullName');
        debugPrint('ADD VAULT scope: ${_scope.name}');
        debugPrint('ADD VAULT familyId: $familyId');
        debugPrint('ADD VAULT ownerUserId: $ownerUserId');
        debugPrint('ADD VAULT ownerEmail: $ownerEmail');

        await context.read<VaultCubit>().createVault(
              name: fullName,
              targetAmount: target,
              initialAmount: initial,
              savingPurpose: category.isNotEmpty ? category : null,
              savingFrequency: _frequency,
              periodicTargetAmount: periodicTarget,
              deadline: _selectedDeadline,
              scope: _scope,
              familyId: familyId,
              ownerUserId: ownerUserId,
              ownerEmail: ownerEmail,
              ownerName: ownerName,
              priority: _priority,
              iconName: _iconName,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pos tabungan berhasil dibuat!'), backgroundColor: AppColors.riskSafe),
          );
          Navigator.pop(context);
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat pos tabungan: $e'), backgroundColor: AppColors.riskCritical),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Widget _buildPriorityPill(VaultPriority value, String label, Color color) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.dataLabel.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Pos Dana', border: OutlineInputBorder()),
            validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              bool isHead = false;
              if (state is AuthAuthenticated) {
                isHead = state.user.role == UserRole.headOfFamily;
              }
              return DropdownButtonFormField<SavingsVaultScope>(
                initialValue: _scope,
                decoration: const InputDecoration(labelText: 'Jenis Tabungan', border: OutlineInputBorder()),
                items: [
                  if (isHead)
                    const DropdownMenuItem(value: SavingsVaultScope.family, child: Text('Tabungan Keluarga')),
                  const DropdownMenuItem(value: SavingsVaultScope.personal, child: Text('Tabungan Pribadi')),
                ],
                onChanged: isHead
                    ? (v) {
                        if (v != null) setState(() => _scope = v);
                      }
                    : null,
                disabledHint: const Text('Tabungan Pribadi'),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.user.role != UserRole.headOfFamily) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Tabungan Keluarga hanya dapat dibuat oleh Kepala Keluarga.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Kategori (Misal: Liburan, Medis, dll)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Text('Prioritas', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriorityPill(VaultPriority.high, 'Tinggi', AppColors.riskCritical),
              const SizedBox(width: 8),
              _buildPriorityPill(VaultPriority.medium, 'Sedang', AppColors.riskWarning),
              const SizedBox(width: 8),
              _buildPriorityPill(VaultPriority.low, 'Rendah', AppColors.riskSafe),
            ],
          ),
          const SizedBox(height: 16),
          Text('Pilih Ikon', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _vaultIconChoices.map((entry) {
              final isSelected = _iconName == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _iconName = entry.key),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                    ),
                    child: Icon(entry.value, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Target Nominal',
              prefixText: 'Rp ',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (val == null || val <= 0) return 'Masukkan target nominal yang valid';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _initialController,
            decoration: const InputDecoration(
              labelText: 'Dana Awal (Opsional)',
              prefixText: 'Rp ',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SavingFrequency>(
            initialValue: _frequency,
            decoration: const InputDecoration(labelText: 'Frekuensi Menabung', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: SavingFrequency.weekly, child: Text('Mingguan')),
              DropdownMenuItem(value: SavingFrequency.monthly, child: Text('Bulanan')),
              DropdownMenuItem(value: SavingFrequency.yearly, child: Text('Tahunan')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _frequency = v);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _periodicTargetController,
            decoration: const InputDecoration(labelText: 'Target Setoran Periodik (Rp, Opsional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _deadlineController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Tenggat Waktu (Opsional)', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (picked != null) {
                setState(() {
                  _selectedDeadline = picked;
                  _deadlineController.text = DateFormat('dd MMM yyyy').format(picked);
                });
              }
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Simpan Pos Tabungan',
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class InviteMemberForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const InviteMemberForm({super.key, required this.onSuccess});

  @override
  State<InviteMemberForm> createState() => _InviteMemberFormState();
}

class _InviteMemberFormState extends State<InviteMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRelation = 'Pasangan';

  final List<String> _relations = ['Pasangan', 'Anak', 'Orang Tua', 'Saudara', 'Lainnya'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFamilyInvitationCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Undangan berhasil dibuat! Kode Undangan: ${state.inviteCode}'),
              backgroundColor: AppColors.riskSafe,
              duration: const Duration(seconds: 6),
            ),
          );
          Navigator.pop(context);
          widget.onSuccess();
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.riskCritical),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap Anggota', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Anggota', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRelation,
                decoration: const InputDecoration(labelText: 'Hubungan Keluarga', border: OutlineInputBorder()),
                items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _selectedRelation = v!),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Buat Undangan',
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                InviteFamilyMemberRequested(
                                  fullName: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  relation: _selectedRelation,
                                  isActive: true,
                                ),
                              );
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddVaultDepositForm extends StatefulWidget {
  final SavingsVault vault;
  final VoidCallback onSuccess;

  const AddVaultDepositForm({super.key, required this.vault, required this.onSuccess});

  @override
  State<AddVaultDepositForm> createState() => _AddVaultDepositFormState();
}

class _AddVaultDepositFormState extends State<AddVaultDepositForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final amount = double.parse(_amountController.text);
        final note = _noteController.text.trim();
        await context.read<VaultCubit>().addDeposit(widget.vault.id, amount, note: note.isNotEmpty ? note : null);
        if (mounted) {
          Navigator.pop(context);
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah setoran: $e'), backgroundColor: AppColors.riskCritical),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Nominal Setoran (Rp)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (val == null || val <= 0) return 'Masukkan jumlah nominal yang valid';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Catatan (Opsional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Simpan Setoran',
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class SubtractVaultBalanceForm extends StatefulWidget {
  final SavingsVault vault;
  final VoidCallback onSuccess;

  const SubtractVaultBalanceForm({super.key, required this.vault, required this.onSuccess});

  @override
  State<SubtractVaultBalanceForm> createState() => _SubtractVaultBalanceFormState();
}

class _SubtractVaultBalanceFormState extends State<SubtractVaultBalanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final amount = double.parse(_amountController.text);
        final note = _noteController.text.trim();
        await context.read<VaultCubit>().subtractBalance(widget.vault.id, amount, note: note.isNotEmpty ? note : null);
        if (mounted) {
          Navigator.pop(context);
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengurangi saldo: $e'), backgroundColor: AppColors.riskCritical),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Nominal Pengurangan (Rp)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (val == null || val <= 0) return 'Masukkan jumlah nominal yang valid';
              if (val > widget.vault.savedAmount) return 'Nominal pengurangan melebihi saldo tabungan.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Catatan (Opsional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Kurangi Saldo',
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class DataPrivacyModal extends StatelessWidget {
  const DataPrivacyModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, size: 48, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Penyimpanan Lokal & Privasi',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 12),
        Text(
          'LifeGuard Finance dirancang dengan prinsip local-first. Seluruh data keuangan, simulasi krisis, riwayat dana darurat, dan informasi keluarga Anda disimpan secara aman langsung di memori perangkat Anda (Local Storage Hive).\n\nKami tidak mengirimkan data sensitif keuangan Anda ke server mana pun untuk menjaga kerahasiaan penuh.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Saya Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class AboutModal extends StatelessWidget {
  const AboutModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(Icons.shield_moon_rounded, size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'LifeGuard Finance',
            style: AppTextStyles.heading2,
          ),
        ),
        Center(
          child: Text(
            'v1.0.0 (Beta Lokal)',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Aplikasi pencegahan krisis keuangan keluarga secara kolaboratif. Dikembangkan sebagai sistem edukasi mitigasi risiko finansial (Financial Vulnerability Score) berbasis local storage mandiri.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tutup', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}
