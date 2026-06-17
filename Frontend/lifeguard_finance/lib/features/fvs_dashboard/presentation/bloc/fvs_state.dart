import 'package:equatable/equatable.dart';
import '../../domain/entities/fvs_score_entity.dart';

abstract class FvsState extends Equatable {
  const FvsState();

  @override
  List<Object?> get props => [];
}

class FvsInitial extends FvsState {}

class FvsLoading extends FvsState {}

class FvsLoaded extends FvsState {
  final FvsScore score;
  
  const FvsLoaded(this.score);

  @override
  List<Object?> get props => [score];
}

class FvsNoProfile extends FvsState {}

class FvsError extends FvsState {
  final String message;
  
  const FvsError(this.message);

  @override
  List<Object?> get props => [message];
}
