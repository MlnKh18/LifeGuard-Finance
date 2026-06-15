import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class EarlyWarningPage extends StatelessWidget {
  const EarlyWarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistem Peringatan Dini')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_active_outlined, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Early Warning System', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk me-manage notifikasi peringatan kerentanan keuangan keluarga.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
