import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_guard_finance/app.dart';

void main() {
  testWidgets('LifeGuard App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LifeGuardApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
