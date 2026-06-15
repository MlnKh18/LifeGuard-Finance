import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Pages
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/family_profile/presentation/pages/family_profile_page.dart';
import '../../features/fvs_dashboard/presentation/pages/dashboard_page.dart';
import '../../features/emergency_simulation/presentation/pages/simulation_page.dart';
import '../../features/recommendation/presentation/pages/recommendation_page.dart';
import '../../features/smart_routing/presentation/pages/smart_routing_page.dart';
import '../../features/anomaly_detection/presentation/pages/expense_anomaly_page.dart';
import '../../features/early_warning/presentation/pages/early_warning_page.dart';
import '../../features/literacy/presentation/pages/literacy_page.dart';
import '../../features/savings_vault/presentation/pages/savings_vault_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/rewards/presentation/pages/reward_page.dart';
import '../../features/settings/presentation/pages/profile_settings_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/family-profile',
        builder: (context, state) => const FamilyProfilePage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) => const SimulationPage(),
      ),
      GoRoute(
        path: '/recommendation',
        builder: (context, state) => const RecommendationPage(),
      ),
      GoRoute(
        path: '/smart-routing',
        builder: (context, state) => const SmartRoutingPage(),
      ),
      GoRoute(
        path: '/expense-anomaly',
        builder: (context, state) => const ExpenseAnomalyPage(),
      ),
      GoRoute(
        path: '/early-warning',
        builder: (context, state) => const EarlyWarningPage(),
      ),
      GoRoute(
        path: '/literacy',
        builder: (context, state) => const LiteracyPage(),
      ),
      GoRoute(
        path: '/savings-vault',
        builder: (context, state) => const SavingsVaultPage(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityPage(),
      ),
      GoRoute(
        path: '/reward',
        builder: (context, state) => const RewardPage(),
      ),
      GoRoute(
        path: '/profile-settings',
        builder: (context, state) => const ProfileSettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.uri.path}'),
      ),
    ),
  );
}
