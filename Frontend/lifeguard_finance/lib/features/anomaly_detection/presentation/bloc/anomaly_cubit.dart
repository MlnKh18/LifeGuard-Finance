import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/repositories/anomaly_repository.dart';
import 'anomaly_state.dart';

class AnomalyCubit extends Cubit<AnomalyState> {
  final AnomalyRepository anomalyRepository;
  final HiveService hiveService;
  StreamSubscription? _profileSubscription;
  StreamSubscription? _recordsSubscription;
  StreamSubscription? _anomaliesSubscription;

  AnomalyCubit({
    required this.anomalyRepository,
    required this.hiveService,
  }) : super(AnomalyLoading()) {
    _profileSubscription = hiveService.watchKey(LocalKeys.familyProfile).listen((_) {
      loadAnomalies(showLoading: false);
    });
    _recordsSubscription = hiveService.watchKey(LocalKeys.financeRecords).listen((_) {
      loadAnomalies(showLoading: false);
    });
    _anomaliesSubscription = hiveService.watchKey(LocalKeys.anomalyResults).listen((_) {
      loadAnomalies(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _recordsSubscription?.cancel();
    _anomaliesSubscription?.cancel();
    return super.close();
  }

  Future<void> loadAnomalies({bool showLoading = true}) async {
    try {
      if (showLoading) {
        emit(AnomalyLoading());
      }
      final anomalies = await anomalyRepository.getLatestAnomalies();
      final recentRecords = await anomalyRepository.getRecentCombinedRecords();
      final monthlyTrend = await anomalyRepository.getMonthlyTrend();
      emit(AnomalyLoaded(
        anomalies: anomalies,
        monthlyTrend: monthlyTrend,
        recentCombinedRecords: recentRecords,
      ));
    } catch (e) {
      emit(AnomalyError('Gagal memuat deteksi anomali: $e'));
    }
  }
}
