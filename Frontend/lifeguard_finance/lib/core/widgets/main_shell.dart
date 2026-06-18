import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Ringkasan'),
    _NavItem(icon: Icons.science_rounded, label: 'Sandbox'),
    _NavItem(icon: Icons.groups_rounded, label: 'Komunitas'),
    _NavItem(icon: Icons.shield_rounded, label: 'Mitigasi'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          for (final item in _items)
            BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
