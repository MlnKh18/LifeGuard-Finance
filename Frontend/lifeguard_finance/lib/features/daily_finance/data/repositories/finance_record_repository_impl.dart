import 'package:flutter/foundation.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/finance_record_entity.dart';
import '../../domain/repositories/finance_record_repository.dart';

import '../../../../core/network/api_client.dart';

class FinanceRecordRepositoryImpl implements FinanceRecordRepository {
  final HiveService hiveService;
  final AuthRepository authRepository;
  final ApiClient apiClient;

  FinanceRecordRepositoryImpl({
    required this.hiveService,
    required this.authRepository,
    required this.apiClient,
  });

  static const String _recordKey = LocalKeys.financeRecords;

  @override
  Future<List<FinanceRecord>> getRecords() async {
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();

    final currentUserId = currentUser?.userId ?? '';
    final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';

    final rawData = hiveService.getData(_recordKey);
    final rawList = rawData is List ? rawData : <dynamic>[];

    final records = rawList.map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      return FinanceRecord.fromJson(json);
    }).toList();

    // Sync with API in background
    apiClient.dio.get('/incomes').catchError((e) => debugPrint('Sync error'));
    apiClient.dio.get('/expenses').catchError((e) => debugPrint('Sync error'));

    return records;
  }

  Future<void> _saveRecords(List<FinanceRecord> records) async {
    final jsonList = records.map((record) => record.toJson()).toList();
    await hiveService.saveData(_recordKey, jsonList);
  }

  @override
  Future<List<FinanceRecord>> getRecordsByFamily(String familyId) async {
    final records = await getRecords();
    return records.where((r) => r.familyId == familyId).toList();
  }

  @override
  Future<List<FinanceRecord>> getRecordsByUser(String userId) async {
    final records = await getRecords();
    return records.where((r) => r.userId == userId).toList();
  }

  @override
  Future<void> createRecord(FinanceRecord record) async {
    debugPrint('================ CREATE FINANCE RECORD ================');
    debugPrint('type: ${record.type}');
    debugPrint('category: ${record.category}');
    debugPrint('amount: ${record.amount}');
    debugPrint('familyId: ${record.familyId}');
    debugPrint('userId: ${record.userId}');
    debugPrint('userEmail: ${record.userEmail}');

    // Sync to API
    try {
      final endpoint = record.type == FinanceRecordType.income ? '/incomes' : '/expenses';
      await apiClient.dio.post(endpoint, data: {
        'amount': record.amount,
        'category': record.category.toUpperCase().replaceAll(' ', '_'),
        'description': record.notes ?? '',
        'date': record.recordDate.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Finance API Create Error: $e');
    }

    final records = await getRecords();
    final updatedRecords = [...records, record];
    await _saveRecords(updatedRecords);
  }

  @override
  Future<void> updateRecord(FinanceRecord updatedRecord) async {
    final records = await getRecords();
    final updatedRecords = records.map((r) {
      if (r.recordId == updatedRecord.recordId) {
        return updatedRecord;
      }
      return r;
    }).toList();
    await _saveRecords(updatedRecords);
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    final records = await getRecords();
    final updatedRecords = records.where((r) => r.recordId != recordId).toList();
    await _saveRecords(updatedRecords);
  }

  @override
  Future<List<FinanceRecord>> getExpenseRecords() async {
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();
    final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';
    final records = await getRecords();
    return records
        .where((r) => r.familyId == currentFamilyId && r.type == FinanceRecordType.expense)
        .toList();
  }

  @override
  Future<List<FinanceRecord>> getIncomeRecords() async {
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();
    final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';
    final records = await getRecords();
    return records
        .where((r) => r.familyId == currentFamilyId && r.type == FinanceRecordType.income)
        .toList();
  }

  @override
  Future<List<FinanceRecord>> getMonthlyRecords(DateTime month) async {
    final session = await authRepository.getCurrentSession();
    final currentUser = await authRepository.getCurrentUser();
    final currentFamilyId = session?.currentFamilyId ?? currentUser?.familyId ?? '';
    final records = await getRecords();
    return records.where((r) {
      return r.familyId == currentFamilyId &&
          r.recordDate.year == month.year &&
          r.recordDate.month == month.month;
    }).toList();
  }
}
