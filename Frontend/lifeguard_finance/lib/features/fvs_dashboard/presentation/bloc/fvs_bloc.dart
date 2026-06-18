import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../data/datasources/fvs_calculator.dart';
import '../../domain/entities/fvs_score_entity.dart';
import 'fvs_event.dart';
import 'fvs_state.dart';

class FvsBloc extends Bloc<FvsEvent, FvsState> {
  final FamilyProfileRepository familyProfileRepository;
  final FvsCalculator fvsCalculator;
  final HiveService hiveService;

  FvsBloc({
    required this.familyProfileRepository,
    required this.fvsCalculator,
    required this.hiveService,
  }) : super(FvsInitial()) {
    on<LoadFvs>(_onLoadFvs);
    on<CalculateFvs>(_onCalculateFvs);
  }

  Future<void> _onLoadFvs(LoadFvs event, Emitter<FvsState> emit) async {
    emit(FvsLoading());
    try {
      final rawScore = hiveService.getData(LocalKeys.fvsScore);
      if (rawScore != null) {
        final jsonMap = Map<String, dynamic>.from(rawScore as Map);
        final score = FvsScore.fromJson(jsonMap);
        final failureOrProfile = await familyProfileRepository.getFamilyProfile();
        await failureOrProfile.fold(
          (failure) async => emit(FvsError(failure.message)),
          (profile) async {
            if (profile == null) {
              emit(FvsNoProfile());
            } else {
              emit(FvsLoaded(score, profile));
            }
          },
        );
      } else {
        add(CalculateFvs());
      }
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
