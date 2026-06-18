import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterHeadOfFamilyPage extends StatefulWidget {
  const RegisterHeadOfFamilyPage({super.key});

  @override
  State<RegisterHeadOfFamilyPage> createState() => _RegisterHeadOfFamilyPageState();
}

class _RegisterHeadOfFamilyPageState extends State<RegisterHeadOfFamilyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _agreedToPrivacy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _familyNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToPrivacy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus menyetujui kebijakan privasi.'), backgroundColor: AppColors.riskWarning),
        );
        return;
      }
      context.read<AuthBloc>().add(RegisterHeadOfFamilyRequested(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            familyName: _familyNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Daftar Kepala Keluarga')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthRegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registrasi Berhasil!'), backgroundColor: AppColors.riskSafe),
              );
              context.go('/family-profile');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.riskCritical),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lengkapi Data Anda', style: AppTextStyles.heading2),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Kata Sandi', border: OutlineInputBorder()),
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(labelText: 'Konfirmasi Kata Sandi', border: OutlineInputBorder()),
                        obscureText: true,
                        validator: (v) => v != _passwordController.text ? 'Kata sandi tidak sama' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _familyNameController,
                        decoration: const InputDecoration(labelText: 'Nama Keluarga (Contoh: Keluarga Budi)', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'Nama keluarga wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Nomor HP (Opsional)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToPrivacy,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _agreedToPrivacy = val ?? false),
                          ),
                          const Expanded(
                            child: Text('Saya setuju dengan syarat dan ketentuan privasi aplikasi (Penyimpanan lokal).', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Daftar Sekarang',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : () => _onRegister(),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/login'),
                          child: const Text('Sudah punya akun? Masuk'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
