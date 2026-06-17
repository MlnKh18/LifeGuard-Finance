import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/family_profile_entity.dart';
import '../bloc/family_profile_bloc.dart';
import '../bloc/family_profile_event.dart';
import '../bloc/family_profile_state.dart';

class FamilyProfilePage extends StatelessWidget {
  const FamilyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FamilyProfileBloc>(
      create: (context) => getIt<FamilyProfileBloc>()..add(LoadFamilyProfile()),
      child: const FamilyProfileFormView(),
    );
  }
}

class FamilyProfileFormView extends StatefulWidget {
  const FamilyProfileFormView({super.key});

  @override
  State<FamilyProfileFormView> createState() => _FamilyProfileFormViewState();
}

class _FamilyProfileFormViewState extends State<FamilyProfileFormView> {
  final _formKey = GlobalKey<FormState>();

  final _fixedIncomeController = TextEditingController();
  final _variableIncomeController = TextEditingController();
  final _routineExpensesController = TextEditingController();
  final _debtPaymentsController = TextEditingController();
  final _liquidSavingsController = TextEditingController();
  final _totalDependentsController = TextEditingController();

  bool _hasBpjs = false;
  bool _hasAdditionalInsurance = false;

  @override
  void dispose() {
    _fixedIncomeController.dispose();
    _variableIncomeController.dispose();
    _routineExpensesController.dispose();
    _debtPaymentsController.dispose();
    _liquidSavingsController.dispose();
    _totalDependentsController.dispose();
    super.dispose();
  }

  void _populateForm(FamilyFinanceProfile? profile) {
    if (profile == null) return;
    _fixedIncomeController.text = profile.fixedIncome.toStringAsFixed(0);
    _variableIncomeController.text = profile.variableIncome.toStringAsFixed(0);
    _routineExpensesController.text = profile.routineExpenses.toStringAsFixed(0);
    _debtPaymentsController.text = profile.debtPayments.toStringAsFixed(0);
    _liquidSavingsController.text = profile.liquidSavings.toStringAsFixed(0);
    _totalDependentsController.text = profile.totalDependents.toString();
    _hasBpjs = profile.hasBpjs;
    _hasAdditionalInsurance = profile.hasAdditionalInsurance;
  }

  String? _validateRequiredNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return '$fieldName harus berupa angka';
    }
    if (parsed < 0) {
      return '$fieldName tidak boleh negatif';
    }
    return null;
  }

  String? _validateOptionalNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional fields can be empty (defaults to 0)
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return '$fieldName harus berupa angka';
    }
    if (parsed < 0) {
      return '$fieldName tidak boleh negatif';
    }
    return null;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final fixedIncome = double.parse(_fixedIncomeController.text);
    final variableIncome = double.tryParse(_variableIncomeController.text) ?? 0.0;
    final routineExpenses = double.parse(_routineExpensesController.text);
    final debtPayments = double.tryParse(_debtPaymentsController.text) ?? 0.0;
    final liquidSavings = double.tryParse(_liquidSavingsController.text) ?? 0.0;
    final totalDependents = int.tryParse(_totalDependentsController.text) ?? 0;

    final profile = FamilyFinanceProfile(
      fixedIncome: fixedIncome,
      variableIncome: variableIncome,
      routineExpenses: routineExpenses,
      debtPayments: debtPayments,
      liquidSavings: liquidSavings,
      totalDependents: totalDependents,
      hasBpjs: _hasBpjs,
      hasAdditionalInsurance: _hasAdditionalInsurance,
    );

    context.read<FamilyProfileBloc>().add(SaveFamilyProfileEvent(profile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Keuangan Keluarga'),
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Lewati', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: BlocConsumer<FamilyProfileBloc, FamilyProfileState>(
        listener: (context, state) {
          if (state is FamilyProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil keuangan berhasil disimpan!'),
                backgroundColor: AppColors.riskSafe,
              ),
            );
            context.go('/dashboard');
          } else if (state is FamilyProfileLoaded) {
            _populateForm(state.profile);
          } else if (state is FamilyProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.riskCritical,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FamilyProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Lengkapi Data Keuangan',
                    subtitle: 'Masukkan rincian keuangan keluarga Anda secara manual. Kami menjamin kerahasiaan data Anda yang disimpan 100% lokal di perangkat ini.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Pendapatan Box
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pendapatan Bulanan', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                        const Divider(height: 20, color: AppColors.border),
                        _buildTextField(
                          controller: _fixedIncomeController,
                          label: 'Pendapatan Tetap Bulanan (Rp)',
                          hint: 'Contoh: 7500000',
                          validator: (val) => _validateRequiredNumber(val, 'Pendapatan tetap'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _variableIncomeController,
                          label: 'Pendapatan Tidak Tetap Bulanan (Rp)',
                          hint: 'Contoh: 1500000 (jika ada)',
                          validator: (val) => _validateOptionalNumber(val, 'Pendapatan tidak tetap'),
                        ),
                      ],
                    ),
                  ),

                  // Pengeluaran & Hutang Box
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pengeluaran & Kewajiban', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                        const Divider(height: 20, color: AppColors.border),
                        _buildTextField(
                          controller: _routineExpensesController,
                          label: 'Pengeluaran Rutin Bulanan (Rp)',
                          hint: 'Contoh: 4000000',
                          validator: (val) => _validateRequiredNumber(val, 'Pengeluaran rutin'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _debtPaymentsController,
                          label: 'Cicilan Bulanan (Rp)',
                          hint: 'Contoh: 1200000 (jika ada)',
                          validator: (val) => _validateOptionalNumber(val, 'Cicilan bulanan'),
                        ),
                      ],
                    ),
                  ),

                  // Aset & Tanggungan Box
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tabungan & Anggota Keluarga', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                        const Divider(height: 20, color: AppColors.border),
                        _buildTextField(
                          controller: _liquidSavingsController,
                          label: 'Tabungan Likuid / Dana Darurat (Rp)',
                          hint: 'Contoh: 15000000',
                          validator: (val) => _validateOptionalNumber(val, 'Tabungan likuid'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _totalDependentsController,
                          label: 'Jumlah Anggota Keluarga Tanggungan',
                          hint: 'Contoh: 3',
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return null;
                            final parsed = int.tryParse(val);
                            if (parsed == null) return 'Jumlah tanggungan harus berupa angka bulat';
                            if (parsed < 0) return 'Jumlah tanggungan tidak boleh negatif';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Proteksi Kesehatan & Jiwa Box
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Proteksi & Jaminan Kesehatan', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                        const Divider(height: 20, color: AppColors.border),
                        
                        // BPJS Switch
                        SwitchListTile(
                          title: const Text('Status Kepesertaan BPJS', style: AppTextStyles.bodyMedium),
                          subtitle: const Text('Anggota keluarga memiliki jaminan BPJS Kesehatan aktif', style: AppTextStyles.bodySmall),
                          value: _hasBpjs,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _hasBpjs = val),
                        ),
                        
                        // Additional Insurance Switch
                        SwitchListTile(
                          title: const Text('Status Asuransi Tambahan', style: AppTextStyles.bodyMedium),
                          subtitle: const Text('Keluarga memiliki asuransi swasta tambahan (jiwa/kesehatan)', style: AppTextStyles.bodySmall),
                          value: _hasAdditionalInsurance,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _hasAdditionalInsurance = val),
                        ),
                      ],
                    ),
                  ),

                  // Submit Button
                  PrimaryButton(
                    text: 'Simpan Profil & Lanjut ke Dashboard',
                    onPressed: _submitForm,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.riskCritical),
        ),
      ),
    );
  }
}
