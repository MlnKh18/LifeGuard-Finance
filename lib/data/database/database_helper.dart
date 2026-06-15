import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/finance_profile.dart';
import '../models/fvs_score.dart';
import '../models/simulation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lifeguard_finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const nullableTextType = 'TEXT';

    // 1. Create family_profiles table
    await db.execute('''
      CREATE TABLE family_profiles (
        profile_id $textType PRIMARY KEY,
        monthly_income $realType,
        monthly_expense $realType,
        essential_expense $realType,
        non_essential_expense $realType,
        liquid_savings $realType,
        total_debt $realType,
        monthly_debt_payment $realType,
        dependents_count $integerType,
        has_health_protection $integerType,
        has_life_protection $integerType,
        income_type $textType,
        household_type $textType,
        age_range $nullableTextType,
        created_at $textType
      )
    ''');

    // 2. Create fvs_scores table
    await db.execute('''
      CREATE TABLE fvs_scores (
        score_id $textType PRIMARY KEY,
        profile_id $nullableTextType,
        total_score $integerType,
        category $textType,
        income_stability_score $integerType,
        expense_ratio_score $integerType,
        emergency_fund_score $integerType,
        debt_burden_score $integerType,
        dependent_load_score $integerType,
        protection_readiness_score $integerType,
        shock_absorption_score $integerType,
        calculated_at $textType,
        FOREIGN KEY (profile_id) REFERENCES family_profiles (profile_id) ON DELETE CASCADE
      )
    ''');

    // 3. Create simulations table
    await db.execute('''
      CREATE TABLE simulations (
        simulation_id $textType PRIMARY KEY,
        profile_id $nullableTextType,
        scenario_type $textType,
        scenario_duration_months $integerType,
        scenario_amount $realType,
        projected_score $integerType,
        survival_months $realType,
        monthly_deficit $realType,
        created_at $textType,
        FOREIGN KEY (profile_id) REFERENCES family_profiles (profile_id) ON DELETE CASCADE
      )
    ''');

    // 4. Create savings_vaults table
    await db.execute('''
      CREATE TABLE savings_vaults (
        vault_id $textType PRIMARY KEY,
        profile_id $nullableTextType,
        goal_type $textType,
        target_amount $realType,
        current_amount $realType,
        priority $integerType,
        updated_at $textType
      )
    ''');

    // 5. Create notifications table
    await db.execute('''
      CREATE TABLE notifications (
        notification_id $textType PRIMARY KEY,
        type $textType,
        message $textType,
        is_read $integerType,
        created_at $textType
      )
    ''');

    // 6. Create expenses table for Anomaly Detection
    await db.execute('''
      CREATE TABLE expenses (
        expense_id $textType PRIMARY KEY,
        category $textType,
        amount $realType,
        period_month $textType,
        is_routine $integerType,
        is_anomaly $integerType,
        anomaly_severity $textType,
        created_at $textType
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const textType = 'TEXT NOT NULL';
      const integerType = 'INTEGER NOT NULL';
      const realType = 'REAL NOT NULL';
      const nullableTextType = 'TEXT';

      // Add tables that were not present in v1
      await db.execute('''
        CREATE TABLE savings_vaults (
          vault_id $textType PRIMARY KEY,
          profile_id $nullableTextType,
          goal_type $textType,
          target_amount $realType,
          current_amount $realType,
          priority $integerType,
          updated_at $textType
        )
      ''');

      await db.execute('''
        CREATE TABLE notifications (
          notification_id $textType PRIMARY KEY,
          type $textType,
          message $textType,
          is_read $integerType,
          created_at $textType
        )
      ''');

      await db.execute('''
        CREATE TABLE expenses (
          expense_id $textType PRIMARY KEY,
          category $textType,
          amount $realType,
          period_month $textType,
          is_routine $integerType,
          is_anomaly $integerType,
          anomaly_severity $textType,
          created_at $textType
        )
      ''');
    }
  }

  // --- Profile Operations ---
  Future<int> saveProfile(FamilyFinanceProfile profile) async {
    final db = await instance.database;
    return await db.insert(
      'family_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FamilyFinanceProfile?> getLatestProfile() async {
    final db = await instance.database;
    final maps = await db.query(
      'family_profiles',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return FamilyFinanceProfile.fromMap(maps.first);
    }
    return null;
  }

  // --- FVS Score Operations ---
  Future<int> insertScore(FVSScore score) async {
    final db = await instance.database;
    return await db.insert(
      'fvs_scores',
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FVSScore>> getScoreHistory() async {
    final db = await instance.database;
    final result = await db.query('fvs_scores', orderBy: 'calculated_at DESC');
    return result.map((json) => FVSScore.fromMap(json)).toList();
  }

  // --- Simulation Operations ---
  Future<int> insertSimulation(ScenarioSimulation simulation) async {
    final db = await instance.database;
    return await db.insert(
      'simulations',
      simulation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScenarioSimulation>> getSimulationHistory() async {
    final db = await instance.database;
    final result = await db.query('simulations', orderBy: 'created_at DESC');
    return result.map((json) => ScenarioSimulation.fromMap(json)).toList();
  }

  // --- Savings Vault Operations ---
  Future<int> saveVault(Map<String, dynamic> vaultMap) async {
    final db = await instance.database;
    return await db.insert(
      'savings_vaults',
      vaultMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getVaults() async {
    final db = await instance.database;
    return await db.query('savings_vaults', orderBy: 'priority ASC');
  }

  Future<int> deleteVault(String vaultId) async {
    final db = await instance.database;
    return await db.delete(
      'savings_vaults',
      where: 'vault_id = ?',
      whereArgs: [vaultId],
    );
  }

  // --- Notification Operations ---
  Future<int> insertNotification(Map<String, dynamic> notificationMap) async {
    final db = await instance.database;
    return await db.insert(
      'notifications',
      notificationMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await instance.database;
    return await db.query('notifications', orderBy: 'created_at DESC');
  }

  Future<int> markNotificationAsRead(String id) async {
    final db = await instance.database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'notification_id = ?',
      whereArgs: [id],
    );
  }

  // --- Expense Log Operations ---
  Future<int> saveExpense(Map<String, dynamic> expenseMap) async {
    final db = await instance.database;
    return await db.insert(
      'expenses',
      expenseMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await instance.database;
    return await db.query('expenses', orderBy: 'created_at DESC');
  }

  // --- Privacy: Clear All Data ---
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('simulations');
    await db.delete('fvs_scores');
    await db.delete('savings_vaults');
    await db.delete('notifications');
    await db.delete('expenses');
    await db.delete('family_profiles');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
