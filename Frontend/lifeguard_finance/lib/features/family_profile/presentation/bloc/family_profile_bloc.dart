import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_family_profile.dart';
import '../../domain/usecases/save_family_profile.dart';
import 'family_profile_event.dart';
import 'family_profile_state.dart';

class FamilyProfileBloc extends Bloc<FamilyProfileEvent, FamilyProfileState> {
  final GetFamilyProfile getFamilyProfile;
  final SaveFamilyProfile saveFamilyProfile;

  FamilyProfileBloc({
    required this.getFamilyProfile,
    required this.saveFamilyProfile,
  }) : super(FamilyProfileInitial()) {
    on<LoadFamilyProfile>(_onLoadFamilyProfile);
    on<SaveFamilyProfileEvent>(_onSaveFamilyProfile);
  }

  Future<void> _onLoadFamilyProfile(
    LoadFamilyProfile event,
    Emitter<FamilyProfileState> emit,
  ) async {
    emit(FamilyProfileLoading());
    final failureOrProfile = await getFamilyProfile();
    failureOrProfile.fold(
      (failure) => emit(FamilyProfileError(failure.message)),
      (profile) => emit(FamilyProfileLoaded(profile)),
    );
  }

  Future<void> _onSaveFamilyProfile(
    SaveFamilyProfileEvent event,
    Emitter<FamilyProfileState> emit,
  ) async {
    emit(FamilyProfileLoading());
    final failureOrSuccess = await saveFamilyProfile(event.profile);
    failureOrSuccess.fold(
      (failure) => emit(FamilyProfileError(failure.message)),
      (_) => emit(FamilyProfileSaved()),
    );
  }
}
