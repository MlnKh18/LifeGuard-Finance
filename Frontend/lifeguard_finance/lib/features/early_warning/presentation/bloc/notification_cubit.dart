import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../anomaly_detection/data/datasources/anomaly_detection_service.dart';
import '../../../anomaly_detection/domain/entities/expense_transaction.dart';
import '../../../daily_finance/domain/entities/finance_record_entity.dart';
import '../../../emergency_simulation/domain/entities/simulation_result.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../../fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
import '../../data/datasources/early_warning_rule_checker.dart';
import '../../data/datasources/notification_service.dart';
import '../../domain/entities/early_warning.dart';
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
          final currentScore =
              _readScore(LocalKeys.fvsScore) ?? fvsCalculator.calculate(profile);
          final previousScore = _readScore(LocalKeys.previousFvsScore);

          // ─── Ambil familyId dari sesi auth ───
          final authRaw =
              hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.authSession);
          final sessionFamilyId = authRaw?['currentFamilyId'] as String? ??
              authRaw?['familyId'] as String? ??
              '';

          // ─── Baca transaksi dari financeRecords (sumber data Catatan Harian) ───
          final rawRecords = hiveService.getData(LocalKeys.financeRecords);
          final rawList = rawRecords is List ? rawRecords : <dynamic>[];

          final familyExpenses = rawList
              .map((item) {
                try {
                  return FinanceRecord.fromJson(
                      Map<String, dynamic>.from(item as Map));
                } catch (_) {
                  return null;
                }
              })
              .whereType<FinanceRecord>()
              .where((r) =>
                  (sessionFamilyId.isEmpty || r.familyId == sessionFamilyId) &&
                  r.type == FinanceRecordType.expense)
              .toList();

          // Konversi ke ExpenseTransaction untuk analisis anomali
          final transactions = familyExpenses
              .map((r) => ExpenseTransaction(
                    id: r.recordId,
                    category: getCategoryLabel(r.category),
                    amount: r.amount,
                    date: r.recordDate,
                    note: r.notes,
                  ))
              .toList();

          final anomalyResults =
              anomalyDetectionService.analyzeCategories(transactions);

          final simRaw = hiveService.getData(LocalKeys.emergencySimulation);
          final latestSimulation = simRaw != null
              ? SimulationResult.fromJson(
                  Map<String, dynamic>.from(simRaw as Map))
              : null;

          final warnings = ruleChecker.check(
            familyId: sessionFamilyId,
            profile: profile,
            currentScore: currentScore,
            previousScore: previousScore,
            anomalyResults: anomalyResults,
            latestSimulation: latestSimulation,
          );

          // ─── Gabungkan dengan stored early warnings (dari addRecord) ───
          final earlyWarningRaw =
              hiveService.getData(LocalKeys.earlyWarnings);
          final earlyWarningList =
              earlyWarningRaw is List ? earlyWarningRaw : <dynamic>[];
          final storedWarnings = earlyWarningList
              .map((item) {
                try {
                  return EarlyWarning.fromJson(
                      Map<String, dynamic>.from(item as Map));
                } catch (_) {
                  return null;
                }
              })
              .whereType<EarlyWarning>()
              .where((w) =>
                  (sessionFamilyId.isEmpty || w.familyId == sessionFamilyId) &&
                  !w.isRead)
              .toList();

          // Hindari duplikat per sourceId
          final allSourceIds = warnings.map((w) => w.sourceId).toSet();
          final uniqueStoredWarnings = storedWarnings
              .where((w) => !allSourceIds.contains(w.sourceId))
              .toList();

          final combined = [
            ...warnings,
            ...uniqueStoredWarnings,
          ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(NotificationLoaded(combined));
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

  /// Fires a local notification for every currently active warning.
  Future<void> sendTestNotifications() async {
    final current = state;
    if (current is! NotificationLoaded) return;
    for (final warning in current.warnings) {
      await notificationService.showWarning(warning);
    }
  }
}
