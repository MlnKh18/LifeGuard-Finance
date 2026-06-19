import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/reward_service.dart';
import '../../domain/entities/reward_badge.dart';
import '../../domain/entities/reward_point.dart';

class RewardState extends Equatable {
  final int points;
  final RewardBadge badge;
  final List<RewardPoint> ledger;

  const RewardState({this.points = 0, this.badge = starterSaverBadge, this.ledger = const []});

  @override
  List<Object?> get props => [points, badge, ledger];
}

class RewardCubit extends Cubit<RewardState> {
  final RewardService rewardService;

  RewardCubit({required this.rewardService}) : super(const RewardState());

  Future<void> loadPoints() async {
    final ledger = await rewardService.getLedger();
    final points = rewardService.totalPoints(ledger);
    emit(RewardState(points: points, badge: rewardService.badgeForPoints(points), ledger: ledger));
  }

  Future<void> addPoints(int amount, {RewardSource source = RewardSource.literacyModule, String sourceId = 'module'}) async {
    final ledger = await rewardService.addPoints(source, sourceId, amount);
    final points = rewardService.totalPoints(ledger);
    emit(RewardState(points: points, badge: rewardService.badgeForPoints(points), ledger: ledger));
  }
}
