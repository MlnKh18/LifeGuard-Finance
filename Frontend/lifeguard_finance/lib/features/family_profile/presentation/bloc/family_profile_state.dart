import 'package:equatable/equatable.dart';
import '../../domain/entities/family_profile_entity.dart';

abstract class FamilyProfileState extends Equatable {
  const FamilyProfileState();
  
  @override
  List<Object?> get props => [];
}

class FamilyProfileInitial extends FamilyProfileState {}

class FamilyProfileLoading extends FamilyProfileState {}

class FamilyProfileLoaded extends FamilyProfileState {
  final FamilyFinanceProfile? profile;
  
  const FamilyProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FamilyProfileSaved extends FamilyProfileState {}

class FamilyProfileError extends FamilyProfileState {
  final String message;
  
  const FamilyProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
