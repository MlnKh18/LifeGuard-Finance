import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ActivateFamilyMemberPage extends StatefulWidget {
  const ActivateFamilyMemberPage({super.key});

  @override
  State<ActivateFamilyMemberPage> createState() => _ActivateFamilyMemberPageState();
}

class _ActivateFamilyMemberPageState extends State<ActivateFamilyMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _familyCodeController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _familyCodeController.dispose();
    _inviteCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onActivate() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ActivateFamilyMemberInvitationRequested(
          email: _emailController.text,
          familyCode: _familyCodeController.text,
          inviteCode: _inviteCodeController.text,
          newPassword: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Aktivasi Anggota')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aktivasi Berhasil! Selamat datang di keluarga.'),
                backgroundColor: AppColors.riskSafe,
              ),
            );
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.riskCritical,
              ),
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
                    Text('Aktivasi Undangan', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text(
                      'Gunakan kode keluarga LGF dan kode undangan INV yang diberikan oleh Kepala Keluarga.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan email Anda',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Email wajib diisi.';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(v)) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _familyCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Keluarga (Family Code)',
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: LGF-123456',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Kode keluarga wajib diisi.';
                        }
                        if (!v.toUpperCase().startsWith('LGF-')) {
                          return 'Kode keluarga harus diawali LGF-.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _inviteCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Undangan (Invite Code)',
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: INV-123456',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Kode undangan wajib diisi.';
                        }
                        if (!v.toUpperCase().startsWith('INV-')) {
                          return 'Kode undangan harus diawali INV-.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Buat Kata Sandi Baru',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password wajib diisi.';
                        }
                        if (v.length < 6) {
                          return 'Password minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Kata Sandi Baru',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return 'Konfirmasi password tidak sesuai.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: isLoading ? 'Memverifikasi...' : 'Aktivasi Akun',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _onActivate,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
