import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_summary.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileSummary summary;

  const ProfileLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ProfileEmpty extends ProfileState {}

class ProfileClearSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
