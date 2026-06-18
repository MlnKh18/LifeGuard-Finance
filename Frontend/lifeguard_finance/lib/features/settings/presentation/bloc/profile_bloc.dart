import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileSummary>(_onLoadProfileSummary);
    on<ClearProfileLocalData>(_onClearProfileLocalData);
  }

  Future<void> _onLoadProfileSummary(LoadProfileSummary event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final summary = await repository.getProfileSummary();
      emit(ProfileLoaded(summary));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onClearProfileLocalData(ClearProfileLocalData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await repository.clearLocalProfileData();
      emit(ProfileClearSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
