import 'package:equatable/equatable.dart';

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

  const AnomalyResult({
    required this.anomalyId,
    required this.familyId,
    required this.userId,
    required this.userEmail,
    required this.recordId,
    required this.category,
    required this.currentAmount,
    required this.averageAmount,
    required this.increasePercentage,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory AnomalyResult.fromJson(Map<String, dynamic> json) {
    return AnomalyResult(
      anomalyId: json['anomalyId'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
      recordId: json['recordId'] as String,
      category: json['category'] as String,
      currentAmount: (json['currentAmount'] as num).toDouble(),
      averageAmount: (json['averageAmount'] as num).toDouble(),
      increasePercentage: (json['increasePercentage'] as num).toDouble(),
      status: AnomalyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AnomalyStatus.normal,
      ),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      ];
}
