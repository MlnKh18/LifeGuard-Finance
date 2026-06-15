import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class SimulationPage extends StatelessWidget {
  const SimulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi Skenario Darurat')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Emergency Simulation', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk menguji ketahanan dana darurat keluarga terhadap skenario kritis.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
