import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_role.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        final router = GoRouter.of(context);
        if (state is AuthAuthenticated) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              if (state.user.role == UserRole.headOfFamily && !state.isFamilyProfileCompleted) {
                router.go('/family-profile');
              } else {
                router.go('/dashboard');
              }
            }
          });
        } else if (state is AuthUnauthenticated) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) router.go('/onboarding');
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'LifeGuard Finance',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Fintech Preventif Keluarga',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
