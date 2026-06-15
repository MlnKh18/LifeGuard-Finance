import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Points')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Community Reward Points', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk poin reward yang diperoleh dari membaca modul literasi.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
