import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AuthSession extends Equatable {
  final String currentUserId;
  final String currentFamilyId;
  final UserRole currentUserRole;
  final bool isLoggedIn;
  final DateTime loginAt;

  const AuthSession({
    required this.currentUserId,
    required this.currentFamilyId,
    required this.currentUserRole,
    this.isLoggedIn = true,
    required this.loginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentUserId': currentUserId,
      'currentFamilyId': currentFamilyId,
      'currentUserRole': currentUserRole.key,
      'isLoggedIn': isLoggedIn,
      'loginAt': loginAt.toIso8601String(),
    };
  }

  factory AuthSession.fromJson(Map<dynamic, dynamic> json) {
    return AuthSession(
      currentUserId: json['currentUserId'] ?? '',
      currentFamilyId: json['currentFamilyId'] ?? '',
      currentUserRole: UserRoleExtension.fromKey(json['currentUserRole'] ?? 'family_member'),
      isLoggedIn: json['isLoggedIn'] ?? false,
      loginAt: json['loginAt'] != null ? DateTime.parse(json['loginAt']) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        currentUserId,
        currentFamilyId,
        currentUserRole,
        isLoggedIn,
        loginAt,
      ];
}
