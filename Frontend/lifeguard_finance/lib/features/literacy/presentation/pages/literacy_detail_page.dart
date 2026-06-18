import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LiteracyDetailPage extends StatelessWidget {
  final String moduleId;

  const LiteracyDetailPage({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Modul', style: AppTextStyles.heading3),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Modul ID: $moduleId', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text('Modul ini dapat dibaca langsung di sini, atau jika memiliki tautan eksternal akan dibuka di browser.', 
                style: AppTextStyles.bodyMedium, 
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
