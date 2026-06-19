import 'package:equatable/equatable.dart';
import '../../domain/entities/smart_routing_plan.dart';

abstract class SmartRoutingState extends Equatable {
  const SmartRoutingState();

  @override
  List<Object?> get props => [];
}

class SmartRoutingLoading extends SmartRoutingState {}

class SmartRoutingNoProfile extends SmartRoutingState {}

class SmartRoutingLoaded extends SmartRoutingState {
  final SmartRoutingPlan plan;

  const SmartRoutingLoaded(this.plan);

  @override
  List<Object?> get props => [plan];
}

class SmartRoutingError extends SmartRoutingState {
  final String message;

  const SmartRoutingError(this.message);

  @override
  List<Object?> get props => [message];
}
