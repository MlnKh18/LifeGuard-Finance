import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../data/datasources/simulation_calculator.dart';
import '../../domain/entities/simulation_result.dart';
import '../../domain/entities/simulation_input.dart';
import 'simulation_event.dart';
import 'simulation_state.dart';

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final FamilyProfileRepository familyProfileRepository;
  final SimulationCalculator simulationCalculator;
  final HiveService hiveService;
  StreamSubscription? _profileSubscription;
  SimulationInput? _lastInput;

  SimulationBloc({
    required this.familyProfileRepository,
    required this.simulationCalculator,
    required this.hiveService,
  }) : super(SimulationInitial()) {
    on<RunSimulation>(_onRunSimulation);
    on<LoadSavedSimulation>(_onLoadSavedSimulation);

    _profileSubscription = hiveService.watchKey(LocalKeys.familyProfile).listen((event) {
      if (_lastInput != null) {
        add(RunSimulation(_lastInput!));
      } else {
        add(LoadSavedSimulation());
      }
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRunSimulation(RunSimulation event, Emitter<SimulationState> emit) async {
    _lastInput = event.input;
    emit(SimulationLoading());
    final failureOrProfile = await familyProfileRepository.getFamilyProfile();
    await failureOrProfile.fold(
      (failure) async => emit(SimulationError(failure.message)),
      (profile) async {
        if (profile == null) {
          emit(SimulationNoProfile());
        } else {
          try {
            final result = simulationCalculator.simulate(
              profile: profile,
              input: event.input,
            );
            await hiveService.saveData(LocalKeys.emergencySimulation, result.toJson());
            await hiveService.saveData('${LocalKeys.emergencySimulation}_input', {
              'scenarioType': event.input.scenarioType.index,
              'parameterValue': event.input.parameterValue,
              'secondaryParameterValue': event.input.secondaryParameterValue,
            });
            emit(SimulationSuccess(result));
          } catch (e) {
            emit(SimulationError('Simulasi gagal dihitung: $e'));
          }
        }
      },
    );
  }

  Future<void> _onLoadSavedSimulation(LoadSavedSimulation event, Emitter<SimulationState> emit) async {
    emit(SimulationLoading());
    try {
      final rawInput = hiveService.getData('${LocalKeys.emergencySimulation}_input');
      if (rawInput != null) {
        final map = Map<String, dynamic>.from(rawInput as Map);
        _lastInput = SimulationInput(
          scenarioType: ScenarioType.values[map['scenarioType'] as int],
          parameterValue: (map['parameterValue'] as num).toDouble(),
          secondaryParameterValue: (map['secondaryParameterValue'] as num?)?.toDouble(),
        );
      } else {
        _lastInput = null;
      }

      final rawResult = hiveService.getData(LocalKeys.emergencySimulation);
      if (rawResult != null) {
        final jsonMap = Map<String, dynamic>.from(rawResult as Map);
        final result = SimulationResult.fromJson(jsonMap);
        emit(SimulationSuccess(result));
      } else {
        emit(SimulationInitial());
      }
    } catch (e) {
      emit(SimulationError('Gagal memuat hasil simulasi sebelumnya: $e'));
    }
  }
}
