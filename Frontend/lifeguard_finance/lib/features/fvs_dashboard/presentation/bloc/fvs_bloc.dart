import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../data/datasources/fvs_calculator.dart';
import 'fvs_event.dart';
import 'fvs_state.dart';

class FvsBloc extends Bloc<FvsEvent, FvsState> {
  final FamilyProfileRepository familyProfileRepository;
  final FvsCalculator fvsCalculator;
  final HiveService hiveService;
  StreamSubscription? _profileSubscription;

  FvsBloc({
    required this.familyProfileRepository,
    required this.fvsCalculator,
    required this.hiveService,
  }) : super(FvsInitial()) {
    on<LoadFvs>(_onLoadFvs);
    on<CalculateFvs>(_onCalculateFvs);

    _profileSubscription = hiveService.watchKey(LocalKeys.familyProfile).listen((event) {
      add(LoadFvs());
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadFvs(LoadFvs event, Emitter<FvsState> emit) async {
    emit(FvsLoading());
    try {
      final failureOrProfile = await familyProfileRepository.getFamilyProfile();
      await failureOrProfile.fold(
        (failure) async => emit(FvsError(failure.message)),
        (profile) async {
          if (profile == null) {
            emit(FvsNoProfile());
          } else {
            final calculatedScore = fvsCalculator.calculate(profile);
            await hiveService.saveData(LocalKeys.fvsScore, calculatedScore.toJson());
            emit(FvsLoaded(calculatedScore, profile));
          }
        },
      );
    } catch (e) {
      emit(FvsError('Gagal memuat skor FVS: $e'));
    }
  }

  Future<void> _onCalculateFvs(CalculateFvs event, Emitter<FvsState> emit) async {
    emit(FvsLoading());
    final failureOrProfile = await familyProfileRepository.getFamilyProfile();
    await failureOrProfile.fold(
      (failure) async => emit(FvsError(failure.message)),
      (profile) async {
        if (profile == null) {
          emit(FvsNoProfile());
        } else {
          final calculatedScore = fvsCalculator.calculate(profile);
          final previousRaw = hiveService.getData(LocalKeys.fvsScore);
          if (previousRaw != null) {
            await hiveService.saveData(LocalKeys.previousFvsScore, previousRaw);
          }
          await hiveService.saveData(LocalKeys.fvsScore, calculatedScore.toJson());
          emit(FvsLoaded(calculatedScore, profile));
        }
      },
    );
  }
}
