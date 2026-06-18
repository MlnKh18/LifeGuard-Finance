import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Pages
import '../../core/di/injection.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/core/permission_helper.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/family_profile/presentation/pages/family_profile_page.dart';
import '../../features/fvs_dashboard/presentation/pages/dashboard_page.dart';
import '../../features/emergency_simulation/presentation/pages/simulation_page.dart';
import '../../features/recommendation/presentation/pages/recommendation_page.dart';
import '../../features/smart_routing/presentation/pages/smart_routing_page.dart';
import '../../features/anomaly_detection/presentation/pages/expense_anomaly_page.dart';
import '../../features/anomaly_detection/presentation/pages/transaction_detail_page.dart';
import '../../features/early_warning/presentation/pages/early_warning_page.dart';
import '../../features/literacy/presentation/pages/literacy_page.dart';
import '../../features/literacy/presentation/pages/literacy_detail_page.dart';
import '../../features/savings_vault/presentation/pages/savings_vault_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/rewards/presentation/pages/reward_page.dart';
import '../../features/auth/presentation/pages/auth_entry_page.dart';
import '../../features/auth/presentation/pages/register_head_of_family_page.dart';
import '../../features/auth/presentation/pages/family_members_page.dart';
import '../../features/auth/presentation/pages/invite_family_member_page.dart';
import '../../features/auth/presentation/pages/activate_family_member_page.dart';
import '../../features/auth/presentation/pages/access_denied_page.dart';
import '../../features/settings/presentation/pages/profile_settings_page.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isGoingToCommunity = state.uri.path == '/community';
      if (isGoingToCommunity) {
        final session = getIt<AuthRepository>().getCachedSession();
        if (session == null || !session.isLoggedIn) {
          return '/login';
        }
        if (!PermissionHelper.canAccessCommunity(session.currentUserRole)) {
          return '/access-denied';
        }
      }
      return null;
    },
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
        path: '/auth-entry',
        builder: (context, state) => const AuthEntryPage(),
      ),
      GoRoute(
        path: '/register-head',
        builder: (context, state) => const RegisterHeadOfFamilyPage(),
      ),
      GoRoute(
        path: '/family-members',
        builder: (context, state) => const FamilyMembersPage(),
      ),
      GoRoute(
        path: '/invite-family-member',
        builder: (context, state) => const InviteFamilyMemberPage(),
      ),
      GoRoute(
        path: '/activate-member',
        builder: (context, state) => const ActivateFamilyMemberPage(),
      ),
      GoRoute(
        path: '/access-denied',
        builder: (context, state) => const AccessDeniedPage(),
      ),
      GoRoute(
        path: '/family-profile',
        builder: (context, state) => const FamilyProfilePage(),
      ),
      GoRoute(
        path: '/smart-routing',
        builder: (context, state) => const SmartRoutingPage(),
      ),
      GoRoute(
        path: '/expense-anomaly',
        builder: (context, state) => const ExpenseAnomalyPage(),
        routes: [
          GoRoute(
            path: ':transactionId',
            builder: (context, state) => TransactionDetailPage(
              transactionId: state.pathParameters['transactionId'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/early-warning',
        builder: (context, state) => const EarlyWarningPage(),
      ),
      GoRoute(
        path: '/literacy',
        builder: (context, state) => const LiteracyPage(),
        routes: [
          GoRoute(
            path: ':moduleId',
            builder: (context, state) => LiteracyDetailPage(moduleId: state.pathParameters['moduleId'] ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: '/savings-vault',
        builder: (context, state) => const SavingsVaultPage(),
      ),
      GoRoute(
        path: '/reward',
        builder: (context, state) => const RewardPage(),
      ),
      // 5 main tabs (Komunitas, Ringkasan, Sandbox, Mitigasi, Profil) share a
      // persistent bottom nav, matching the Stitch design system's canonical
      // tab set — see docs/stitch_screens/mapping_notes.md.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/simulation',
                builder: (context, state) => const SimulationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recommendation',
                builder: (context, state) => const RecommendationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile-settings',
                builder: (context, state) => const ProfileSettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.uri.path}'),
      ),
    ),
  );
}
