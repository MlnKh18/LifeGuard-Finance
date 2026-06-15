import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.l, vertical: AppStyles.m),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(), // Spacer
                
                // Brand Center Logo & Tagline
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.m),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                      child: const Icon(
                        LucideIcons.shieldAlert,
                        size: 72,
                        color: Colors.white,
                      ),
                    ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: AppStyles.m),
                    
                    const Text(
                      'LifeGuard Finance',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: AppStyles.s),
                    
                    Text(
                      'Deteksi Risiko Finansial Keluarga\nSebelum Krisis Terjadi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),

                // Features Intro Card & Call To Action
                Column(
                  children: [
                    // Small feature badges
                    Container(
                      padding: const EdgeInsets.all(AppStyles.m),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: AppStyles.radiusMedium,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureBadge(LucideIcons.activity, 'Detect FVS'),
                          _buildFeatureBadge(LucideIcons.flaskConical, 'Simulate'),
                          _buildFeatureBadge(LucideIcons.compass, 'Guide'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),

                    const SizedBox(height: AppStyles.l),

                    // Primary Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.3),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mulai Cek Kondisi Keluarga',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: AppStyles.s),
                          Icon(LucideIcons.arrowRight, size: 20),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),
                    
                    const SizedBox(height: AppStyles.m),
                    
                    // Disclaimer
                    Text(
                      'Aplikasi ini bersifat simulatif & edukatif sesuai kaidah perencanaan keuangan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: AppStyles.xs),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
