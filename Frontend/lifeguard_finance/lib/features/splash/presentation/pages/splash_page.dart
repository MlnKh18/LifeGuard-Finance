import 'dart:ui';
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [Color(0xFFE3F6F2), AppColors.background],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(160),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withAlpha(200), width: 1.5),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 72, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('LifeGuard Finance', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Pelindung Finansial Pribadi Anda',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'MENYIAPKAN KEAMANAN DATA...',
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
