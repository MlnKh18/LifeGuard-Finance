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
      version: 1,
      onCreate: _createDB,
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

  // --- Privacy: Clear All Data ---
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('simulations');
    await db.delete('fvs_scores');
    await db.delete('family_profiles');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
