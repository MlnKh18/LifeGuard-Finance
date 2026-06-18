import 'package:equatable/equatable.dart';
import '../../domain/entities/fvs_score_entity.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';

abstract class FvsState extends Equatable {
  const FvsState();

  @override
  List<Object?> get props => [];
}

class FvsInitial extends FvsState {}

class FvsLoading extends FvsState {}

class FvsLoaded extends FvsState {
  final FvsScore score;
  final FamilyFinanceProfile profile;

  const FvsLoaded(this.score, this.profile);

  @override
  List<Object?> get props => [score, profile];
}

class FvsNoProfile extends FvsState {}

class FvsError extends FvsState {
  final String message;
  
  const FvsError(this.message);

  @override
  List<Object?> get props => [message];
}
