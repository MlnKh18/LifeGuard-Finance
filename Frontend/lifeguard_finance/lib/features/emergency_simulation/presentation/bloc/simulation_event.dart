import 'package:equatable/equatable.dart';
import '../../domain/entities/simulation_input.dart';

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();

  @override
  List<Object?> get props => [];
}

class RunSimulation extends SimulationEvent {
  final SimulationInput input;
  
  const RunSimulation(this.input);

  @override
  List<Object?> get props => [input];
}

class LoadSavedSimulation extends SimulationEvent {}
