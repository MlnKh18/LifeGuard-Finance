import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_guard_finance/app.dart';
import 'package:life_guard_finance/providers/app_providers.dart';
import 'package:life_guard_finance/data/repositories/finance_repository.dart';
import 'package:life_guard_finance/data/repositories/score_repository.dart';
import 'package:life_guard_finance/data/repositories/vault_repository.dart';
import 'package:life_guard_finance/data/repositories/notification_repository.dart';
import 'package:life_guard_finance/data/repositories/expense_repository.dart';
import 'package:life_guard_finance/data/models/finance_profile.dart';
import 'package:life_guard_finance/data/models/fvs_score.dart';
import 'package:life_guard_finance/data/models/simulation.dart';
import 'package:life_guard_finance/data/database/database_helper.dart';

class MockFinanceRepository extends FinanceRepository {
  @override
  Future<FamilyFinanceProfile?> getLatestProfile() async => null;
  @override
  Future<bool> saveProfile(FamilyFinanceProfile profile) async => true;
}

class MockScoreRepository extends ScoreRepository {
  @override
  Future<List<FVSScore>> getScoreHistory() async => [];
  @override
  Future<bool> saveScore(FVSScore score) async => true;
  @override
  Future<List<ScenarioSimulation>> getSimulationHistory() async => [];
  @override
  Future<bool> saveSimulation(ScenarioSimulation simulation) async => true;
  @override
  Future<void> clearAllData() async {}
}

class MockVaultRepository extends VaultRepository {
  MockVaultRepository() : super(DatabaseHelper.instance);
  @override
  Future<List<Map<String, dynamic>>> fetchVaults() async => [];
  @override
  Future<void> addOrUpdateVault(Map<String, dynamic> vaultMap) async {}
  @override
  Future<void> removeVault(String vaultId) async {}
}

class MockNotificationRepository extends NotificationRepository {
  MockNotificationRepository() : super(DatabaseHelper.instance);
  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() async => [];
  @override
  Future<void> addNotification(Map<String, dynamic> notifMap) async {}
  @override
  Future<void> updateNotificationReadStatus(String notifId, int isRead) async {}
}

class MockExpenseRepository extends ExpenseRepository {
  MockExpenseRepository() : super(DatabaseHelper.instance);
  @override
  Future<List<Map<String, dynamic>>> fetchExpenses() async => [];
  @override
  Future<void> addExpense(Map<String, dynamic> expenseMap) async {}
}

void main() {
  testWidgets('LifeGuard App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financeRepositoryProvider.overrideWith((ref) => MockFinanceRepository()),
          scoreRepositoryProvider.overrideWith((ref) => MockScoreRepository()),
          vaultRepositoryProvider.overrideWith((ref) => MockVaultRepository()),
          notificationRepositoryProvider.overrideWith((ref) => MockNotificationRepository()),
          expenseRepositoryProvider.overrideWith((ref) => MockExpenseRepository()),
        ],
        child: const LifeGuardApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Let splash screen animations finish to clear all active timers
    await tester.pump(const Duration(seconds: 5));
  });
}
