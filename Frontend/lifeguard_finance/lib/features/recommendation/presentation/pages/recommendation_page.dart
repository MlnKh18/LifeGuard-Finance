import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Keuangan')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Recommendation Engine', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk menampilkan rekomendasi finansial preventif yang dipersonalisasi.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
