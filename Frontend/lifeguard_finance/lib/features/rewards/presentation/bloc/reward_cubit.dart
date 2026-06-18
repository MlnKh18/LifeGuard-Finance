import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';

class RewardState extends Equatable {
  final int points;
  final String badge;

  const RewardState({this.points = 0, this.badge = 'Starter Saver'});

  @override
  List<Object?> get props => [points, badge];
}

class RewardCubit extends Cubit<RewardState> {
  final HiveService hiveService;

  RewardCubit({required this.hiveService}) : super(const RewardState());

  void loadPoints() {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.rewardPoints);
    final points = (raw?['points'] as num?)?.toInt() ?? 0;
    emit(RewardState(points: points, badge: _badgeForPoints(points)));
  }

  Future<void> addPoints(int amount) async {
    final updatedPoints = state.points + amount;
    final updated = RewardState(points: updatedPoints, badge: _badgeForPoints(updatedPoints));
    emit(updated);
    await hiveService.saveData(LocalKeys.rewardPoints, {
      'points': updated.points,
      'badge': updated.badge,
    });
  }

  String _badgeForPoints(int points) {
    if (points >= 200) return 'Financial Guardian';
    if (points >= 100) return 'Helpful Family';
    if (points >= 50) return 'Emergency Builder';
    return 'Starter Saver';
  }
}
