import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../anomaly_detection/data/datasources/anomaly_detection_service.dart';
import '../../../anomaly_detection/domain/entities/expense_transaction.dart';
import '../../../emergency_simulation/domain/entities/simulation_result.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../../fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
import '../../data/datasources/early_warning_rule_checker.dart';
import '../../data/datasources/notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FamilyProfileRepository familyProfileRepository;
  final FvsCalculator fvsCalculator;
  final AnomalyDetectionService anomalyDetectionService;
  final EarlyWarningRuleChecker ruleChecker;
  final NotificationService notificationService;
  final HiveService hiveService;

  NotificationCubit({
    required this.familyProfileRepository,
    required this.fvsCalculator,
    required this.anomalyDetectionService,
    required this.ruleChecker,
    required this.notificationService,
    required this.hiveService,
  }) : super(NotificationLoading());

  Future<void> loadWarnings() async {
    emit(NotificationLoading());
    final failureOrProfile = await familyProfileRepository.getFamilyProfile();
    await failureOrProfile.fold(
      (failure) async => emit(NotificationError(failure.message)),
      (profile) async {
        if (profile == null) {
          emit(NotificationNoProfile());
          return;
        }
        try {
          final currentScore = _readScore(LocalKeys.fvsScore) ?? fvsCalculator.calculate(profile);
          final previousScore = _readScore(LocalKeys.previousFvsScore);

          final expenseRaw = hiveService.getData(LocalKeys.expenseHistory);
          final transactions = expenseRaw != null
              ? (expenseRaw as List)
                  .map((e) => ExpenseTransaction.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()
              : <ExpenseTransaction>[];
          final anomalyResults = anomalyDetectionService.analyzeCategories(transactions);

          final simRaw = hiveService.getData(LocalKeys.emergencySimulation);
          final latestSimulation =
              simRaw != null ? SimulationResult.fromJson(Map<String, dynamic>.from(simRaw as Map)) : null;

          final warnings = ruleChecker.check(
            profile: profile,
            currentScore: currentScore,
            previousScore: previousScore,
            anomalyResults: anomalyResults,
            latestSimulation: latestSimulation,
          );
          emit(NotificationLoaded(warnings));
        } catch (e) {
          emit(NotificationError('Gagal memeriksa peringatan dini: $e'));
        }
      },
    );
  }

  FvsScore? _readScore(String key) {
    final raw = hiveService.getData(key);
    if (raw == null) return null;
    return FvsScore.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<bool> requestPermission() => notificationService.requestPermission();

  /// Fires a local notification for every currently active warning — used by
  /// the "Test Notifikasi" action on EarlyWarningPage to demonstrate Step 14.
  Future<void> sendTestNotifications() async {
    final current = state;
    if (current is! NotificationLoaded) return;
    for (final warning in current.warnings) {
      await notificationService.showWarning(warning);
    }
  }
}
