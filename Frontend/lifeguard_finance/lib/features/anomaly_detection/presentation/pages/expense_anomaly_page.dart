import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class ExpenseAnomalyPage extends StatelessWidget {
  const ExpenseAnomalyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deteksi Anomali Biaya')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Expense Anomaly Detection', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk analisis anomali pengeluaran keluarga berbasis Z-Score lokal.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
