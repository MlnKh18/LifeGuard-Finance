import 'user_role.dart';

class FamilyInvitation {
  final String invitationId;
  final String familyId;
  final String invitedEmail;
  final String invitedName;
  final String relation;
  final String inviteCode;
  final UserRole roleToAssign;
  final String status; // 'pending', 'accepted', 'rejected'
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  FamilyInvitation({
    required this.invitationId,
    required this.familyId,
    required this.invitedEmail,
    required this.invitedName,
    required this.relation,
    required this.inviteCode,
    this.roleToAssign = UserRole.familyMember,
    this.status = 'pending',
    required this.createdByUserId,
    required this.createdAt,
    this.acceptedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'invitationId': invitationId,
      'familyId': familyId,
      'invitedEmail': invitedEmail,
      'invitedName': invitedName,
      'relation': relation,
      'inviteCode': inviteCode,
      'roleToAssign': roleToAssign.toString(),
      'status': status,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  factory FamilyInvitation.fromJson(Map<dynamic, dynamic> json) {
    return FamilyInvitation(
      invitationId: json['invitationId'] as String,
      familyId: json['familyId'] as String,
      invitedEmail: json['invitedEmail'] as String,
      invitedName: json['invitedName'] as String,
      relation: json['relation'] as String,
      inviteCode: json['inviteCode'] as String,
      roleToAssign: UserRole.values.firstWhere(
        (e) => e.toString() == json['roleToAssign'],
        orElse: () => UserRole.familyMember,
      ),
      status: json['status'] as String,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
    );
  }
}
