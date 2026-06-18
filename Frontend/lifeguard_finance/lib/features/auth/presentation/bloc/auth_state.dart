import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/family_invitation.dart';
import '../../domain/entities/family_account.dart';

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
  final bool isFamilyProfileCompleted;

  const AuthAuthenticated({
    required this.user,
    required this.session,
    required this.isFamilyProfileCompleted,
  });

  @override
  List<Object?> get props => [user, session, isFamilyProfileCompleted];
}

class AuthLogoutSuccess extends AuthState {}

class AuthFamilyInvitationCreated extends AuthState {
  final String inviteCode;

  const AuthFamilyInvitationCreated(this.inviteCode);

  @override
  List<Object?> get props => [inviteCode];
}

class AuthFamilyMembersLoaded extends AuthState {
  final List<AppUser> members;
  final List<FamilyInvitation> invitations;
  final FamilyAccount? family;

  const AuthFamilyMembersLoaded({
    required this.members,
    this.invitations = const [],
    this.family,
  });

  @override
  List<Object?> get props => [members, invitations, family];
}

class AuthFamilyInvitationsLoaded extends AuthState {
  final List<FamilyInvitation> invitations;

  const AuthFamilyInvitationsLoaded(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class AuthAccessDenied extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
