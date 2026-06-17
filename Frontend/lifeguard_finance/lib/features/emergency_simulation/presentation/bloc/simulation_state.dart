import 'package:equatable/equatable.dart';
import '../../domain/entities/simulation_result.dart';

abstract class SimulationState extends Equatable {
  const SimulationState();

  @override
  List<Object?> get props => [];
}

class SimulationInitial extends SimulationState {}

class SimulationLoading extends SimulationState {}

class SimulationSuccess extends SimulationState {
  final SimulationResult result;
  
  const SimulationSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class SimulationNoProfile extends SimulationState {}

class SimulationError extends SimulationState {
  final String message;
  
  const SimulationError(this.message);

  @override
  List<Object?> get props => [message];
}
