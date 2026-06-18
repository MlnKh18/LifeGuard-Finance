import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/core/permission_helper.dart';
import '../di/injection.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

/// Persistent bottom navigation shell for the 5 main app sections, matching
/// the Stitch design system's canonical tab set: Komunitas, Ringkasan,
/// Sandbox, Mitigasi, Profil (see `docs/stitch_screens/mapping_notes.md`).
///
/// The active tab is driven by [navigationShell]'s current branch index —
/// not by per-screen markup — which avoids the wrong-active-tab bug found
/// in the Stitch-generated Komunitas screen.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool showCommunity = false;
        if (state is AuthAuthenticated) {
          showCommunity = PermissionHelper.canAccessCommunity(state.session.currentUserRole);
        } else {
          final cachedSession = getIt<AuthRepository>().getCachedSession();
          if (cachedSession != null) {
            showCommunity = PermissionHelper.canAccessCommunity(cachedSession.currentUserRole);
          }
        }

        final visibleItems = <_NavItem>[];
        final branchMapping = <int>[];

        // Index 0: Dashboard
        visibleItems.add(const _NavItem(icon: Icons.dashboard_rounded, label: 'Ringkasan'));
        branchMapping.add(0);

        // Index 1: Simulation
        visibleItems.add(const _NavItem(icon: Icons.science_rounded, label: 'Sandbox'));
        branchMapping.add(1);

        // Index 2: Community
        if (showCommunity) {
          visibleItems.add(const _NavItem(icon: Icons.groups_rounded, label: 'Komunitas'));
          branchMapping.add(2);
        }

        // Index 3: Anomaly Detection
        visibleItems.add(const _NavItem(icon: Icons.shield_rounded, label: 'Deteksi Anomali'));
        branchMapping.add(3);

        // Index 4: Profile
        visibleItems.add(const _NavItem(icon: Icons.person_rounded, label: 'Profil'));
        branchMapping.add(4);

        int currentBottomNavIndex = branchMapping.indexOf(navigationShell.currentIndex);
        if (currentBottomNavIndex == -1) currentBottomNavIndex = 0; // fallback

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentBottomNavIndex,
            onTap: (index) => navigationShell.goBranch(
              branchMapping[index],
              initialLocation: branchMapping[index] == navigationShell.currentIndex,
            ),
            items: visibleItems.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            )).toList(),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
