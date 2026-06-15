import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Profil')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Profile & Settings', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk konfigurasi akun dan backup data finansial lokal.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
