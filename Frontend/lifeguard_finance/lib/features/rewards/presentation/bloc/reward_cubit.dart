import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reward_repository.dart';
import '../../domain/entities/reward_summary.dart';

abstract class RewardState extends Equatable {
  const RewardState();

  @override
  List<Object?> get props => [];
}

class RewardInitial extends RewardState {}

class RewardLoading extends RewardState {}

class RewardLoaded extends RewardState {
  final RewardSummary summary;

  const RewardLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class RewardError extends RewardState {
  final String message;

  const RewardError(this.message);

  @override
  List<Object?> get props => [message];
}

class RewardCubit extends Cubit<RewardState> {
  final RewardRepository rewardRepository;

  RewardCubit({required this.rewardRepository}) : super(RewardInitial());

  Future<void> loadRewardSummary() async {
    emit(RewardLoading());
    try {
      final summary = await rewardRepository.getRewardSummary();
      emit(RewardLoaded(summary: summary));
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }
}
