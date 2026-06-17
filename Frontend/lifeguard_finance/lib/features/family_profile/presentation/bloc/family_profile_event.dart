import 'package:equatable/equatable.dart';
import '../../domain/entities/family_profile_entity.dart';

abstract class FamilyProfileEvent extends Equatable {
  const FamilyProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadFamilyProfile extends FamilyProfileEvent {}

class SaveFamilyProfileEvent extends FamilyProfileEvent {
  final FamilyFinanceProfile profile;
  
  const SaveFamilyProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
