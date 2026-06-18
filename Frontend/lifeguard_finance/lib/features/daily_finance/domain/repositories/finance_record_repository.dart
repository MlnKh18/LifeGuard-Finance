import '../entities/finance_record_entity.dart';

abstract class FinanceRecordRepository {
  Future<List<FinanceRecord>> getRecords();
  Future<List<FinanceRecord>> getRecordsByFamily(String familyId);
  Future<List<FinanceRecord>> getRecordsByUser(String userId);
  Future<void> createRecord(FinanceRecord record);
  Future<void> updateRecord(FinanceRecord record);
  Future<void> deleteRecord(String recordId);
  Future<List<FinanceRecord>> getExpenseRecords();
  Future<List<FinanceRecord>> getIncomeRecords();
  Future<List<FinanceRecord>> getMonthlyRecords(DateTime month);
}
