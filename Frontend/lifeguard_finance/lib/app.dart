import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_theme.dart';
import 'providers/app_providers.dart';
import 'presentation/screens/onboarding/splash_screen.dart';
import 'presentation/screens/main_navigation.dart';

class LifeGuardApp extends ConsumerWidget {
  const LifeGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStateProvider);

    return MaterialApp(
      title: 'LifeGuard Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: profile == null 
          ? const SplashScreen() 
          : const MainNavigation(),
    );
  }
}
