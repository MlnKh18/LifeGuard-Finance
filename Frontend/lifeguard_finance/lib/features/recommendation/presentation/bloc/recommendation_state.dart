import 'package:equatable/equatable.dart';
import '../../domain/entities/recommendation_entity.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationLoading extends RecommendationState {}

class RecommendationNoProfile extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<Recommendation> tasks;

  const RecommendationLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object?> get props => [message];
}
