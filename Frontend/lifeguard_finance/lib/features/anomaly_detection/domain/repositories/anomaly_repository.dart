import '../../../daily_finance/domain/entities/finance_record_entity.dart';
import '../entities/anomaly_result.dart';

import '../entities/anomaly_combined_record.dart';
import '../entities/monthly_expense_trend.dart';

abstract class AnomalyRepository {
  Future<AnomalyResult?> detectForExpense(FinanceRecord expense);
  Future<List<AnomalyResult>> getAnomalyResults();
  Future<List<AnomalyResult>> getLatestAnomalies();
  Future<List<AnomalyCombinedRecord>> getRecentCombinedRecords();
  Future<List<MonthlyExpenseTrend>> getMonthlyTrend();
}
