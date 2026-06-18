import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class CheckAuthSession extends AuthEvent {}

class RegisterHeadOfFamilyRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String familyName;
  final String phoneNumber;

  const RegisterHeadOfFamilyRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.familyName,
    this.phoneNumber = '',
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

class AddFamilyMemberRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String relation;
  final bool isActive;

  const AddFamilyMemberRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.relation,
    required this.isActive,
  });
}

class LoadFamilyMembers extends AuthEvent {}
