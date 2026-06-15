import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dashboard/dashboard_screen.dart';
import 'simulation/simulation_screen.dart';
import 'action_plan/action_plan_screen.dart';
import 'settings/settings_screen.dart';
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
    const ActionPlanScreen(),
    const SettingsScreen(),
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
            icon: Icon(LucideIcons.clipboardList),
            selectedIcon: Icon(LucideIcons.clipboardList, color: AppColors.primaryLight),
            label: 'Rencana Aksi',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings, color: AppColors.primaryLight),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
