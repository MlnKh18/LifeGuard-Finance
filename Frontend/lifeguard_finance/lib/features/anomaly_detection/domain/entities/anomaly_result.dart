import 'package:equatable/equatable.dart';
import 'expense_transaction.dart';

enum AnomalyStatus {
  normal,
  lightAnomaly,
  highAnomaly,
}

class AnomalyResult extends Equatable {
  final String anomalyId;
  final String familyId;
  final String userId;
  final String userEmail;
  final String recordId;
  final String category;
  final double currentAmount;
  final double averageAmount;
  final double increasePercentage;
  final AnomalyStatus status;
  final String message;
  final DateTime createdAt;

  // Compatibility fields
  final double historicalAverage;
  final double percentageIncrease;
  final AnomalySeverity severity;
  final double estimatedFvsImpact;
  final String warningMessage;

  AnomalyResult({
    this.anomalyId = '',
    this.familyId = '',
    this.userId = '',
    this.userEmail = '',
    this.recordId = '',
    required this.category,
    required this.currentAmount,
    double? averageAmount,
    double? increasePercentage,
    AnomalyStatus? status,
    String? message,
    DateTime? createdAt,
    double? historicalAverage,
    double? percentageIncrease,
    AnomalySeverity? severity,
    this.estimatedFvsImpact = 0.0,
    String? warningMessage,
  })  : averageAmount = averageAmount ?? historicalAverage ?? 0.0,
        increasePercentage = increasePercentage ?? percentageIncrease ?? 0.0,
        status = status ?? (severity == AnomalySeverity.tinggi ? AnomalyStatus.highAnomaly : (severity == AnomalySeverity.ringan ? AnomalyStatus.lightAnomaly : AnomalyStatus.normal)),
        message = message ?? warningMessage ?? '',
        createdAt = createdAt ?? DateTime.now(),
        historicalAverage = historicalAverage ?? averageAmount ?? 0.0,
        percentageIncrease = percentageIncrease ?? increasePercentage ?? 0.0,
        severity = severity ?? (status == AnomalyStatus.highAnomaly ? AnomalySeverity.tinggi : (status == AnomalyStatus.lightAnomaly ? AnomalySeverity.ringan : AnomalySeverity.normal)),
        warningMessage = warningMessage ?? message ?? '';

  factory AnomalyResult.fromJson(Map<String, dynamic> json) {
    final statusVal = AnomalyStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AnomalyStatus.normal,
    );
    final double incPct = (json['increasePercentage'] as num?)?.toDouble() ?? 0.0;
    return AnomalyResult(
      anomalyId: json['anomalyId'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      recordId: json['recordId'] as String? ?? '',
      category: json['category'] as String? ?? '',
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      averageAmount: (json['averageAmount'] as num?)?.toDouble() ?? 0.0,
      increasePercentage: incPct,
      status: statusVal,
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      historicalAverage: (json['averageAmount'] as num?)?.toDouble() ?? 0.0,
      percentageIncrease: incPct,
      severity: statusVal == AnomalyStatus.highAnomaly ? AnomalySeverity.tinggi : (statusVal == AnomalyStatus.lightAnomaly ? AnomalySeverity.ringan : AnomalySeverity.normal),
      estimatedFvsImpact: (json['estimatedFvsImpact'] as num?)?.toDouble() ?? 0.0,
      warningMessage: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anomalyId': anomalyId,
      'familyId': familyId,
      'userId': userId,
      'userEmail': userEmail,
      'recordId': recordId,
      'category': category,
      'currentAmount': currentAmount,
      'averageAmount': averageAmount,
      'increasePercentage': increasePercentage,
      'status': status.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'estimatedFvsImpact': estimatedFvsImpact,
    };
  }

  @override
  List<Object?> get props => [
        anomalyId,
        familyId,
        userId,
        userEmail,
        recordId,
        category,
        currentAmount,
        averageAmount,
        increasePercentage,
        status,
        message,
        createdAt,
        historicalAverage,
        percentageIncrease,
        severity,
        estimatedFvsImpact,
        warningMessage,
      ];
}
