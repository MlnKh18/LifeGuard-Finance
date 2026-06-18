import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  final String userId;
  final String familyId;
  final String fullName;
  final String email;
  final String passwordHash; // Local prototype only
  final UserRole role;
  final String relation;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.userId,
    required this.familyId,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.relation = 'head_of_family',
    this.phoneNumber = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'familyId': familyId,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'role': role.key,
      'relation': relation,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<dynamic, dynamic> json) {
    return AppUser(
      userId: json['userId'] ?? '',
      familyId: json['familyId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      role: UserRoleExtension.fromKey(json['role'] ?? 'family_member'),
      relation: json['relation'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        familyId,
        fullName,
        email,
        passwordHash,
        role,
        relation,
        phoneNumber,
        isActive,
        createdAt,
        updatedAt,
      ];
}
