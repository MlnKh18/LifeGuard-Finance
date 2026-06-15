import '../database/database_helper.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepository(this._dbHelper);

  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    return await _dbHelper.getExpenses();
  }

  Future<void> addExpense(Map<String, dynamic> expenseMap) async {
    await _dbHelper.saveExpense(expenseMap);
  }
}
