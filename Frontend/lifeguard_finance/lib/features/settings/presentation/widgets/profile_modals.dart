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

  bool _loading = false;

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

        await context.read<VaultCubit>().createVault(
              name: fullName,
              targetAmount: target,
              initialAmount: initial,
              savingPurpose: category.isNotEmpty ? category : null,
              savingFrequency: _frequency,
              periodicTargetAmount: periodicTarget,
              deadline: _selectedDeadline,
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
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Kategori (Misal: Liburan, Medis, dll)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _targetController,
            decoration: const InputDecoration(labelText: 'Target Nominal (Rp)', border: OutlineInputBorder()),
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
            decoration: const InputDecoration(labelText: 'Dana Awal (Rp, Opsional)', border: OutlineInputBorder()),
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

class UpdateVaultProgressForm extends StatefulWidget {
  final SavingsVault vault;
  final VoidCallback onSuccess;

  const UpdateVaultProgressForm({super.key, required this.vault, required this.onSuccess});

  @override
  State<UpdateVaultProgressForm> createState() => _UpdateVaultProgressFormState();
}

class _UpdateVaultProgressFormState extends State<UpdateVaultProgressForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final amount = double.parse(_amountController.text);
        await context.read<VaultCubit>().addFunds(widget.vault.id, amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil menabung Rp ${NumberFormat('#,###', 'id_ID').format(amount)} ke ${widget.vault.name}!'),
              backgroundColor: AppColors.riskSafe,
            ),
          );
          Navigator.pop(context);
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah tabangan: $e'), backgroundColor: AppColors.riskCritical),
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
          Text(
            'Pos: ${widget.vault.name}',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Terkumpul: Rp ${NumberFormat('#,###', 'id_ID').format(widget.vault.savedAmount)} / Rp ${NumberFormat('#,###', 'id_ID').format(widget.vault.targetAmount)}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Jumlah Tabungan Baru (Rp)',
              border: OutlineInputBorder(),
              hintText: 'Masukkan nominal',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (val == null || val <= 0) return 'Masukkan jumlah nominal yang valid';
              return null;
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Tabung Sekarang',
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
