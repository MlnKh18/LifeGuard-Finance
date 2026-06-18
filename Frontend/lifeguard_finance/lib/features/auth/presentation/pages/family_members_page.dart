import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(LoadFamilyMembers()),
      child: Scaffold(
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
              if (members.isEmpty) {
                return const Center(child: Text('Belum ada anggota keluarga.'));
              }
              
              // We could also get the family code from AuthSession/FamilyAccount, but we'll focus on the members list for now.
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
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
                },
              );
            }

            return const Center(child: Text('Gagal memuat anggota.'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () async {
                final result = await context.push<bool>('/add-family-member');
                if (result == true) {
                  context.read<AuthBloc>().add(LoadFamilyMembers());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Anggota'),
              backgroundColor: AppColors.primary,
            );
          }
        ),
      ),
    );
  }
}
