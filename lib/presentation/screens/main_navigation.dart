import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dashboard/dashboard_screen.dart';
import 'simulation/simulation_screen.dart';
import 'vault/vault_screen.dart';
import 'insights/insights_screen.dart';
import 'community/community_screen.dart';
import '../../constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SimulationScreen(),
    const VaultScreen(),
    const InsightsScreen(),
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutGrid),
            selectedIcon: Icon(LucideIcons.layoutGrid, color: AppColors.primaryLight),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.flaskConical),
            selectedIcon: Icon(LucideIcons.flaskConical, color: AppColors.primaryLight),
            label: 'Simulasi',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.piggyBank),
            selectedIcon: Icon(LucideIcons.piggyBank, color: AppColors.primaryLight),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.barChart2),
            selectedIcon: Icon(LucideIcons.barChart2, color: AppColors.primaryLight),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users),
            selectedIcon: Icon(LucideIcons.users, color: AppColors.primaryLight),
            label: 'Komunitas',
          ),
        ],
      ),
    );
  }
}
