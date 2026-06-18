import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  final AuthSession session;

  const AuthAuthenticated(this.user, this.session);

  @override
  List<Object?> get props => [user, session];
}

class AuthRegisterSuccess extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final AppUser user;

  const AuthLoginSuccess(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthLogoutSuccess extends AuthState {}

class AuthFamilyMemberAdded extends AuthState {}

class AuthFamilyMembersLoaded extends AuthState {
  final List<AppUser> members;

  const AuthFamilyMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class AuthAccessDenied extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
