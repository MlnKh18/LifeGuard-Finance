import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class InviteFamilyMemberPage extends StatefulWidget {
  const InviteFamilyMemberPage({super.key});

  @override
  State<InviteFamilyMemberPage> createState() => _InviteFamilyMemberPageState();
}

class _InviteFamilyMemberPageState extends State<InviteFamilyMemberPage> {
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

  void _onInvite() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(InviteFamilyMemberRequested(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            relation: _selectedRelation,
            isActive: true,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Undang Anggota')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFamilyInvitationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Undangan berhasil dibuat! Kode Undangan: ${state.inviteCode}'),
                backgroundColor: AppColors.riskSafe,
                duration: const Duration(seconds: 6),
              ),
            );
            context.pop(true); // Return success
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
                    Text('Detail Anggota', style: AppTextStyles.heading2),
                    const SizedBox(height: 16),
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
                      onPressed: isLoading ? null : _onInvite,
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
