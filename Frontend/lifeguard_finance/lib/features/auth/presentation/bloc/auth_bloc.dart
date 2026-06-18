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
    on<AddFamilyMemberRequested>(_onAddFamilyMemberRequested);
    on<LoadFamilyMembers>(_onLoadFamilyMembers);
  }

  Future<void> _onCheckAuthSession(CheckAuthSession event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final session = await repository.getCurrentSession();
      if (session != null && session.isLoggedIn) {
        final user = await repository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user, session));
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
      emit(AuthRegisterSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(event.email, event.password);
      emit(AuthLoginSuccess(user));
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

  Future<void> _onAddFamilyMemberRequested(AddFamilyMemberRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.addFamilyMember(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        relation: event.relation,
        isActive: event.isActive,
      );
      emit(AuthFamilyMemberAdded());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoadFamilyMembers(LoadFamilyMembers event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final members = await repository.getFamilyMembers();
      emit(AuthFamilyMembersLoaded(members));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
