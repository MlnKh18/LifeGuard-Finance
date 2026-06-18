import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(
              Icons.family_restroom_rounded,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 32),
            Text(
              'Lindungi Finansial Keluarga Anda',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Mulai deteksi, simulasikan, dan mitigasi kerentanan finansial keluarga Anda sejak dini secara mandiri dan aman.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            AppCard(
              child: PrimaryButton(
                text: 'Mulai Sekarang',
                onPressed: () {
                  context.go('/register-role');
                },
              ),
            ),
            SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}
