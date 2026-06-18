import 'package:equatable/equatable.dart';

enum EarlyWarningSeverity {
  low,
  medium,
  high,
}

enum EarlyWarningSource {
  fvs,
  simulation,
  anomaly,
  dailyFinance,
}

class EarlyWarning extends Equatable {
  final String warningId;
  final String familyId;
  final String? userId; // Optional, to tie to a specific user or family-wide
  final String title;
  final String message;
  final EarlyWarningSeverity severity;
  final EarlyWarningSource source;
  final String? sourceId;
  final bool isRead;
  final DateTime createdAt;

  const EarlyWarning({
    required this.warningId,
    required this.familyId,
    this.userId,
    required this.title,
    required this.message,
    required this.severity,
    required this.source,
    this.sourceId,
    required this.isRead,
    required this.createdAt,
  });

  EarlyWarning copyWith({
    String? warningId,
    String? familyId,
    String? userId,
    String? title,
    String? message,
    EarlyWarningSeverity? severity,
    EarlyWarningSource? source,
    String? sourceId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return EarlyWarning(
      warningId: warningId ?? this.warningId,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warningId': warningId,
      'familyId': familyId,
      'userId': userId,
      'title': title,
      'message': message,
      'severity': severity.name,
      'source': source.name,
      'sourceId': sourceId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EarlyWarning.fromJson(Map<String, dynamic> json) {
    return EarlyWarning(
      warningId: json['warningId'],
      familyId: json['familyId'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      severity: EarlyWarningSeverity.values.firstWhere((e) => e.name == json['severity']),
      source: EarlyWarningSource.values.firstWhere((e) => e.name == json['source']),
      sourceId: json['sourceId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        warningId,
        familyId,
        userId,
        title,
        message,
        severity,
        source,
        sourceId,
        isRead,
        createdAt,
      ];
}
