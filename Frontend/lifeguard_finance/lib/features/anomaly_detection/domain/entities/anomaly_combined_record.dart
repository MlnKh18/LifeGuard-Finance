import 'package:equatable/equatable.dart';
import '../../../daily_finance/domain/entities/finance_record_entity.dart';
import 'anomaly_result.dart';

class AnomalyCombinedRecord extends Equatable {
  final FinanceRecord record;
  final AnomalyResult? anomaly;

  const AnomalyCombinedRecord({
    required this.record,
    this.anomaly,
  });

  bool get isAnomaly => anomaly != null;

  @override
  List<Object?> get props => [record, anomaly];
}
