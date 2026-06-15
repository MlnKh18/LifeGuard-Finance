import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class SmartRoutingPage extends StatelessWidget {
  const SmartRoutingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Routing')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.alt_route_rounded, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text('Goal-Driven Smart Routing', style: AppTextStyles.heading2),
              SizedBox(height: 8),
              Text('Placeholder untuk panduan wizard alokasi dana darurat dan kebutuhan keluarga.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
