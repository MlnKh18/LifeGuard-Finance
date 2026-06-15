import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class LiteracyPage extends StatelessWidget {
  const LiteracyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Literasi Finansial')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Financial Literacy Modules', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk konten edukasi keuangan keluarga dan modul preventif.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
