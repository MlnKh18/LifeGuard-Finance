import 'package:uuid/uuid.dart';
import '../../../anomaly_detection/domain/entities/anomaly_result.dart';
import '../../../anomaly_detection/domain/entities/expense_transaction.dart';
import '../../../emergency_simulation/domain/entities/simulation_result.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
import '../../domain/entities/early_warning.dart';

/// Evaluates the 6 early-warning trigger rules from the project spec against
/// the latest known state of each feature, and produces a list of active
/// [EarlyWarning]s with ready-to-display Indonesian messages.
class EarlyWarningRuleChecker {
  const EarlyWarningRuleChecker();

  static const double _staleProfileDays = 30;

  List<EarlyWarning> check({
    required FamilyFinanceProfile profile,
    required FvsScore currentScore,
    FvsScore? previousScore,
    List<AnomalyResult> anomalyResults = const [],
    SimulationResult? latestSimulation,
  }) {
    const uuid = Uuid();
    final warnings = <EarlyWarning>[];
    final now = DateTime.now();

    // 1. Skor FVS turun
    if (previousScore != null && currentScore.score < previousScore.score) {
      warnings.add(EarlyWarning(
        id: uuid.v4(),
        type: WarningType.fvsDropped,
        severity: WarningSeverity.critical,
        title: 'Skor FVS Menurun',
        message:
            'Skor FVS turun dari ${previousScore.score.toStringAsFixed(0)} menjadi ${currentScore.score.toStringAsFixed(0)}. Lihat rekomendasi pemulihan.',
        triggeredAt: now,
      ));
    }

    // 2. Dana darurat di bawah 3 bulan
    final monthsCovered = profile.routineExpenses > 0 ? profile.liquidSavings / profile.routineExpenses : 99.0;
    if (monthsCovered < 3.0) {
      warnings.add(EarlyWarning(
        id: uuid.v4(),
        type: WarningType.lowEmergencyFund,
        severity: monthsCovered < 1.5 ? WarningSeverity.critical : WarningSeverity.warning,
        title: 'Dana Darurat Tidak Mencukupi',
        message:
            'Dana darurat Anda hanya cukup untuk ${monthsCovered.toStringAsFixed(1)} bulan. Perkuat cadangan keluarga mulai minggu ini.',
        triggeredAt: now,
      ));
    }

    // 3. Rasio cicilan melewati 35%
    final totalIncome = profile.fixedIncome + profile.variableIncome;
    final debtRatio = totalIncome > 0 ? profile.debtPayments / totalIncome : 0.0;
    if (debtRatio > 0.35) {
      warnings.add(EarlyWarning(
        id: uuid.v4(),
        type: WarningType.highDebtRatio,
        severity: WarningSeverity.warning,
        title: 'Rasio Cicilan Melewati Batas Aman',
        message:
            'Rasio cicilan melewati batas aman (${(debtRatio * 100).toStringAsFixed(0)}%). Pertimbangkan evaluasi ulang kewajiban bulanan.',
        triggeredAt: now,
      ));
    }

    // 4. Ada anomali pengeluaran
    for (final result in anomalyResults.where((r) => r.severity != AnomalySeverity.normal)) {
      warnings.add(EarlyWarning(
        id: uuid.v4(),
        type: WarningType.expenseAnomaly,
        severity: result.severity == AnomalySeverity.tinggi ? WarningSeverity.critical : WarningSeverity.warning,
        title: 'Anomali Pengeluaran: ${result.category}',
        message:
            'Pengeluaran kategori ${result.category} naik ${result.percentageIncrease.toStringAsFixed(0)}% dari pola biasanya.',
        triggeredAt: now,
      ));
    }

    // 5. Pengguna belum memperbarui data keuangan
    if (profile.updatedAt != null) {
      final daysSinceUpdate = now.difference(profile.updatedAt!).inDays;
      if (daysSinceUpdate > _staleProfileDays) {
        warnings.add(EarlyWarning(
          id: uuid.v4(),
          type: WarningType.staleProfile,
          severity: WarningSeverity.info,
          title: 'Data Keuangan Belum Diperbarui',
          message: 'Anda belum memperbarui profil keuangan keluarga selama $daysSinceUpdate hari. Perbarui agar rekomendasi tetap akurat.',
          triggeredAt: now,
        ));
      }
    }

    // 6. Simulasi menunjukkan defisit besar (lebih dari 1 bulan pengeluaran rutin)
    if (latestSimulation != null &&
        profile.routineExpenses > 0 &&
        latestSimulation.potentialDeficit > profile.routineExpenses) {
      warnings.add(EarlyWarning(
        id: uuid.v4(),
        type: WarningType.simulationDeficit,
        severity: WarningSeverity.critical,
        title: 'Simulasi Menunjukkan Defisit Besar',
        message:
            'Simulasi krisis terakhir memproyeksikan defisit besar yang melebihi satu bulan pengeluaran rutin Anda. Tinjau kembali rencana mitigasi.',
        triggeredAt: now,
      ));
    }

    return warnings;
  }
}
