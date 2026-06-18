import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRelation = 'Anak';
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AddFamilyMemberRequested(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            relation: _selectedRelation,
            isActive: _isActive,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tambah Anggota Keluarga')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFamilyMemberAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anggota keluarga berhasil ditambahkan'), backgroundColor: AppColors.riskSafe),
              );
              context.pop(true); // Return true to refresh list
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Anggota', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email / Username', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Kata Sandi Sementara', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRelation,
                      decoration: const InputDecoration(labelText: 'Hubungan Keluarga', border: OutlineInputBorder()),
                      items: ['Anak', 'Pasangan', 'Orang tua', 'Anggota lain'].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRelation = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Status Aktif'),
                      value: _isActive,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Simpan Anggota',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _onSave,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
