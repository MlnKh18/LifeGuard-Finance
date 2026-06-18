import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class FamilyMembersPage extends StatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch loading event to the shared root bloc
    context.read<AuthBloc>().add(LoadFamilyMembersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Keluarga'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => current is AuthFamilyMembersLoaded || current is AuthLoading,
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthFamilyMembersLoaded) {
            final members = state.members;
            final invitations = state.invitations;
            final family = state.family;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (family != null) ...[
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(family.familyName, style: AppTextStyles.heading2),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Family Code: ${family.familyCode}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: AppColors.primary),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: family.familyCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Kode Keluarga disalin ke clipboard!')),
                                  );
                                },
                                tooltip: 'Salin Kode Keluarga',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (members.isEmpty && invitations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('Belum ada anggota keluarga.'),
                    ),
                  )
                else ...[
                  if (members.isNotEmpty) ...[
                    Text('Anggota Aktif', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    ...members.map((member) {
                      final isHead = member.role == UserRole.headOfFamily;
                      return AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isHead ? AppColors.primary : AppColors.secondary.withValues(alpha: 0.2),
                            child: Icon(Icons.person, color: isHead ? Colors.white : AppColors.secondary),
                          ),
                          title: Text(member.fullName, style: AppTextStyles.heading3),
                          subtitle: Text('${member.email} • ${member.relation}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isHead ? AppColors.primary.withValues(alpha: 0.1) : AppColors.textSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isHead ? 'Kepala' : 'Anggota',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isHead ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  if (invitations.isNotEmpty) ...[
                    Text('Undangan Pending', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    ...invitations.map((inv) {
                      return AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(alpha: 0.2),
                            child: const Icon(Icons.mail_outline, color: Colors.orange),
                          ),
                          title: Text(inv.invitedName, style: AppTextStyles.heading3),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${inv.invitedEmail} • ${inv.relation}'),
                              Text('Invite Code: ${inv.inviteCode}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          trailing: const Text(
                            'Pending',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ],
            );
          }

          return const Center(child: Text('Gagal memuat anggota.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>('/invite-family-member');
          if (result == true && context.mounted) {
            context.read<AuthBloc>().add(LoadFamilyMembersRequested());
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Undang Anggota'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
