import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komunitas Keluarga')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Support Community', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk sharing pengalaman finansial keluarga secara anonim.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
