import 'package:equatable/equatable.dart';

class FamilyAccount extends Equatable {
  final String familyId;
  final String familyName;
  final String familyCode;
  final String headUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyAccount({
    required this.familyId,
    required this.familyName,
    required this.familyCode,
    required this.headUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'familyName': familyName,
      'familyCode': familyCode,
      'headUserId': headUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FamilyAccount.fromJson(Map<dynamic, dynamic> json) {
    return FamilyAccount(
      familyId: json['familyId'] ?? '',
      familyName: json['familyName'] ?? '',
      familyCode: json['familyCode'] ?? '',
      headUserId: json['headUserId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        familyId,
        familyName,
        familyCode,
        headUserId,
        createdAt,
        updatedAt,
      ];
}
