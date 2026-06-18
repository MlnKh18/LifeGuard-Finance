import 'package:equatable/equatable.dart';

enum WarningSeverity { info, warning, critical }

enum WarningType {
  fvsDropped,
  lowEmergencyFund,
  highDebtRatio,
  expenseAnomaly,
  staleProfile,
  simulationDeficit,
}

class EarlyWarning extends Equatable {
  final String id;
  final WarningType type;
  final WarningSeverity severity;
  final String title;
  final String message;
  final DateTime triggeredAt;

  const EarlyWarning({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.triggeredAt,
  });

  @override
  List<Object?> get props => [id, type, severity, title, message, triggeredAt];
}
