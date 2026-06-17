import '../../domain/entities/simulation_input.dart';
import '../../domain/entities/simulation_result.dart';
import '../../../fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';

class SimulationCalculator {
  final FvsCalculator fvsCalculator;

  const SimulationCalculator(this.fvsCalculator);

  SimulationResult simulate({
    required FamilyFinanceProfile profile,
    required SimulationInput input,
  }) {
    // FVS Before Simulation
    final fvsBefore = fvsCalculator.calculate(profile);

    // Initial variables to modify
    double fixedIncome = profile.fixedIncome;
    double variableIncome = profile.variableIncome;
    double routineExpenses = profile.routineExpenses;
    double debtPayments = profile.debtPayments;
    double liquidSavings = profile.liquidSavings;
    int totalDependents = profile.totalDependents;
    bool hasBpjs = profile.hasBpjs;
    bool hasAdditionalInsurance = profile.hasAdditionalInsurance;

    double monthsEmergencyFundLasts = 0.0;
    double potentialDeficit = 0.0;
    List<String> affectedIndicators = [];
    String recommendation = '';

    final totalIncomeBefore = fixedIncome + variableIncome;

    switch (input.scenarioType) {
      case ScenarioType.lossOfIncome:
        // parameterValue is PHK duration in months
        fixedIncome = 0.0;
        final totalIncomeAfter = fixedIncome + variableIncome;
        final outlays = routineExpenses + debtPayments;
        final deficitPerMonth = outlays - totalIncomeAfter;

        if (deficitPerMonth > 0) {
          potentialDeficit = deficitPerMonth * input.parameterValue;
          monthsEmergencyFundLasts = liquidSavings / deficitPerMonth;
        } else {
          potentialDeficit = 0.0;
          monthsEmergencyFundLasts = 99.0; // Infinite/Very safe
        }

        affectedIndicators = [
          'S1: Stabilitas Pendapatan (Menurun drastis ke 0%)',
          'S2: Rasio Pengeluaran Rutin (Membengkak karena income turun)',
          'S3: Dana Darurat (Mengalami deplesi cepat)',
          'S7: Kapasitas Surplus Arus Kas (Menjadi defisit/negatif)'
        ];

        recommendation = '⚠️ Kehilangan pekerjaan memicu defisit bulanan. Rekomendasi mitigasi:\n'
            '1. Lakukan audit pengeluaran mendesak (hilangkan biaya non-primer).\n'
            '2. Manfaatkan dana darurat hanya untuk kebutuhan pangan dan cicilan pokok.\n'
            '3. Cari pendapatan alternatif cepat melalui freelance atau bisnis sampingan lokal.';
        break;

      case ScenarioType.medicalEmergency:
        // parameterValue is one-time medical cost (Rp)
        final cost = input.parameterValue;
        if (cost > liquidSavings) {
          potentialDeficit = cost - liquidSavings;
          liquidSavings = 0.0;
        } else {
          liquidSavings = liquidSavings - cost;
          potentialDeficit = 0.0;
        }

        monthsEmergencyFundLasts = routineExpenses > 0 ? liquidSavings / routineExpenses : 99.0;
        affectedIndicators = [
          'S3: Dana Darurat (Menurun langsung sebesar biaya medis)',
          'S7: Kapasitas Surplus (Terbebani pengeluaran tidak terduga)'
        ];

        recommendation = '🚑 Biaya medis darurat menyedot dana likuid Anda. Rekomendasi mitigasi:\n'
            '1. Pastikan seluruh anggota keluarga terdaftar BPJS Kesehatan secara aktif.\n'
            '2. Gunakan fasilitas klaim berjenjang dari faskes terdekat untuk meminimalkan out-of-pocket.\n'
            '3. Jika belum terlindungi, alokasikan premi asuransi swasta dasar segera setelah keuangan pulih.';
        break;

      case ScenarioType.interestRateIncrease:
        // parameterValue is debt payment increase amount (Rp)
        final increase = input.parameterValue;
        debtPayments = debtPayments + increase;

        final totalOutlays = routineExpenses + debtPayments;
        final surplus = totalIncomeBefore - totalOutlays;
        if (surplus < 0) {
          potentialDeficit = -surplus * 12; // Annualized deficit
        }

        monthsEmergencyFundLasts = totalOutlays > totalIncomeBefore && (totalOutlays - totalIncomeBefore) > 0
            ? liquidSavings / (totalOutlays - totalIncomeBefore)
            : 99.0;

        affectedIndicators = [
          'S4: Beban Cicilan/Utang (Porsi cicilan membengkak)',
          'S7: Kapasitas Surplus Arus Kas (Margin tabungan menipis)'
        ];

        recommendation = '📈 Kenaikan cicilan membebani kas rutin bulanan. Rekomendasi mitigasi:\n'
            '1. Hubungi kreditur/bank untuk mengajukan restrukturisasi cicilan (bunga tetap atau perpanjangan tenor).\n'
            '2. Hindari mengambil pinjaman baru untuk membayar cicilan lama (efek gali lubang tutup lubang).\n'
            '3. Prioritaskan pelunasan utang dengan bunga mengambang paling tinggi.';
        break;

      case ScenarioType.inflationNeeds:
        // parameterValue is inflation rate (%)
        final rate = input.parameterValue;
        final oldRoutine = routineExpenses;
        routineExpenses = routineExpenses * (1 + rate / 100);
        final increase = routineExpenses - oldRoutine;
        
        potentialDeficit = increase * 12; // Annualized inflation cost

        monthsEmergencyFundLasts = routineExpenses > 0 ? liquidSavings / routineExpenses : 99.0;
        affectedIndicators = [
          'S2: Rasio Pengeluaran Rutin (Pengeluaran dasar naik)',
          'S3: Dana Darurat (Daya beli dana darurat melemah)',
          'S7: Kapasitas Surplus Arus Kas (Menurun akibat kenaikan harga kebutuhan)'
        ];

        recommendation = '💸 Inflasi menggerogoti daya beli bulanan keluarga. Rekomendasi mitigasi:\n'
            '1. Substitusi barang konsumsi dengan produk alternatif merek lokal yang lebih terjangkau.\n'
            '2. Kurangi frekuensi makan di luar dan kelola pemborosan energi rumah tangga.\n'
            '3. Pertimbangkan berbelanja kebutuhan pokok secara grosir bersama kerabat/tetangga.';
        break;

      case ScenarioType.educationEmergency:
        // parameterValue is one-time education cost (Rp)
        final cost = input.parameterValue;
        if (cost > liquidSavings) {
          potentialDeficit = cost - liquidSavings;
          liquidSavings = 0.0;
        } else {
          liquidSavings = liquidSavings - cost;
          potentialDeficit = 0.0;
        }

        monthsEmergencyFundLasts = routineExpenses > 0 ? liquidSavings / routineExpenses : 99.0;
        affectedIndicators = [
          'S3: Dana Darurat (Digunakan untuk biaya masuk/registrasi)',
          'S7: Kapasitas Surplus (Menurun akibat pengeluaran besar)'
        ];

        recommendation = '🎓 Pengeluaran pendidikan mendadak/masuk sekolah. Rekomendasi mitigasi:\n'
            '1. Tanyakan kepada sekolah/universitas terkait opsi cicilan biaya pangkal tanpa bunga.\n'
            '2. Ajukan program beasiswa berprestasi atau beasiswa bantuan ekonomi dari yayasan terkait.\n'
            '3. Mulai siapkan Savings Vault khusus untuk rencana pendidikan jangka menengah di masa depan.';
        break;

      case ScenarioType.increasedDependents:
        // parameterValue is number of dependents added
        final added = input.parameterValue.toInt();
        totalDependents = totalDependents + added;
        // Assume Rp 750.000 added routine cost per dependent
        routineExpenses = routineExpenses + (added * 750000.0);

        final totalOutlays = routineExpenses + debtPayments;
        final surplus = totalIncomeBefore - totalOutlays;
        if (surplus < 0) {
          potentialDeficit = -surplus * 12;
        }

        monthsEmergencyFundLasts = routineExpenses > 0 ? liquidSavings / routineExpenses : 99.0;
        affectedIndicators = [
          'S2: Rasio Pengeluaran Rutin (Kebutuhan susu, popok, makan naik)',
          'S5: Tanggungan Keluarga (Skor beban tanggungan menurun)',
          'S7: Kapasitas Surplus (Menyempit akibat alokasi belanja baru)'
        ];

        recommendation = '👶 Bertambahnya tanggungan membutuhkan alokasi belanja baru. Rekomendasi mitigasi:\n'
            '1. Lakukan efisiensi pada pos belanja pribadi orang tua (gaya hidup, hiburan).\n'
            '2. Segera daftarkan tanggungan baru ke dalam kartu BPJS Kesehatan keluarga untuk proteksi kesehatan.\n'
            '3. Manfaatkan bantuan program pemerintah lokal jika tersedia (posyandu, imunisasi gratis, dll).';
        break;
    }

    // Recalculate FVS with simulated profile
    final simulatedProfile = FamilyFinanceProfile(
      fixedIncome: fixedIncome,
      variableIncome: variableIncome,
      routineExpenses: routineExpenses,
      debtPayments: debtPayments,
      liquidSavings: liquidSavings,
      totalDependents: totalDependents,
      hasBpjs: hasBpjs,
      hasAdditionalInsurance: hasAdditionalInsurance,
    );

    final fvsAfter = fvsCalculator.calculate(simulatedProfile);
    final scoreDrop = fvsBefore.score - fvsAfter.score;

    return SimulationResult(
      fvsBefore: fvsBefore,
      fvsAfter: fvsAfter,
      scoreDrop: scoreDrop,
      monthsEmergencyFundLasts: monthsEmergencyFundLasts,
      potentialDeficit: potentialDeficit,
      affectedIndicators: affectedIndicators,
      recommendation: recommendation,
    );
  }
}
