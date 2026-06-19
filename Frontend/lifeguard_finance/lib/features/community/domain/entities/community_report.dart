import 'package:equatable/equatable.dart';

enum CommunityReportReason {
  spam,
  inappropriate,
  harmfulAdvice,
  privacyConcern,
  other,
}

class CommunityReport extends Equatable {
  final String reportId;
  final String postId;
  final String reporterUserId;
  final String reporterEmail;
  final CommunityReportReason reason;
  final String description;
  final DateTime createdAt;

  const CommunityReport({
    required this.reportId,
    required this.postId,
    required this.reporterUserId,
    required this.reporterEmail,
    required this.reason,
    required this.description,
    required this.createdAt,
  });

  static CommunityReportReason parseReason(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == 'spam') return CommunityReportReason.spam;
    if (raw == 'inappropriate') return CommunityReportReason.inappropriate;
    if (raw == 'harmfuladvice') return CommunityReportReason.harmfulAdvice;
    if (raw == 'privacyconcern') return CommunityReportReason.privacyConcern;
    return CommunityReportReason.other;
  }

  factory CommunityReport.fromJson(Map<String, dynamic> json) {
    return CommunityReport(
      reportId: json['reportId'] as String? ?? json['id'] as String,
      postId: json['postId'] as String,
      reporterUserId: json['reporterUserId'] as String,
      reporterEmail: json['reporterEmail'] as String,
      reason: parseReason(json['reason']),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'postId': postId,
      'reporterUserId': reporterUserId,
      'reporterEmail': reporterEmail,
      'reason': reason.name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        reportId,
        postId,
        reporterUserId,
        reporterEmail,
        reason,
        description,
        createdAt,
      ];
}
