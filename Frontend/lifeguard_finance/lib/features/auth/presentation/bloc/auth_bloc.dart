import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<CheckAuthSession>(_onCheckAuthSession);
    on<RegisterHeadOfFamilyRequested>(_onRegisterHeadOfFamilyRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<InviteFamilyMemberRequested>(_onInviteFamilyMemberRequested);
    on<ActivateFamilyMemberInvitationRequested>(_onActivateFamilyMemberInvitationRequested);
    on<LoadFamilyMembersRequested>(_onLoadFamilyMembersRequested);
    on<LoadFamilyInvitationsRequested>(_onLoadFamilyInvitationsRequested);
  }

  Future<void> _onCheckAuthSession(CheckAuthSession event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final session = await repository.getCurrentSession();
      if (session != null && session.isLoggedIn) {
        final user = await repository.getCurrentUser();
        if (user != null) {
          final isProfileCompleted = await repository.checkIsFamilyProfileCompleted();
          emit(AuthAuthenticated(user: user, session: session, isFamilyProfileCompleted: isProfileCompleted));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterHeadOfFamilyRequested(RegisterHeadOfFamilyRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.registerHeadOfFamily(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        familyName: event.familyName,
        phoneNumber: event.phoneNumber,
      );
      final session = await repository.getCurrentSession();
      final user = await repository.getCurrentUser();
      if (session != null && user != null) {
        emit(AuthAuthenticated(user: user, session: session, isFamilyProfileCompleted: false));
      } else {
        emit(AuthError('Gagal mengambil data user setelah registrasi'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(event.email, event.password);
      final session = await repository.getCurrentSession();
      final isProfileCompleted = await repository.checkIsFamilyProfileCompleted();
      emit(AuthAuthenticated(user: user, session: session!, isFamilyProfileCompleted: isProfileCompleted));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.logout();
      emit(AuthLogoutSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onInviteFamilyMemberRequested(InviteFamilyMemberRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final inviteCode = await repository.inviteFamilyMember(
        fullName: event.fullName,
        email: event.email,
        relation: event.relation,
        isActive: event.isActive,
      );
      emit(AuthFamilyInvitationCreated(inviteCode));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onActivateFamilyMemberInvitationRequested(ActivateFamilyMemberInvitationRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.activateFamilyMemberInvitation(
        email: event.email,
        familyCode: event.familyCode,
        inviteCode: event.inviteCode,
        newPassword: event.newPassword,
      );
      final session = await repository.getCurrentSession();
      final user = await repository.getCurrentUser();
      if (session != null && user != null) {
        final isProfileCompleted = await repository.checkIsFamilyProfileCompleted();
        emit(AuthAuthenticated(user: user, session: session, isFamilyProfileCompleted: isProfileCompleted));
      } else {
        emit(const AuthError('Aktivasi anggota gagal: Gagal mengambil sesi setelah aktivasi'));
      }
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthError('Aktivasi anggota gagal: $cleanMessage'));
    }
  }

  Future<void> _onLoadFamilyMembersRequested(LoadFamilyMembersRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final members = await repository.getFamilyMembers();
      final invitations = await repository.getFamilyInvitations();
      final family = await repository.getFamilyAccount();
      emit(AuthFamilyMembersLoaded(members: members, invitations: invitations, family: family));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoadFamilyInvitationsRequested(LoadFamilyInvitationsRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final invitations = await repository.getFamilyInvitations();
      emit(AuthFamilyInvitationsLoaded(invitations));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
