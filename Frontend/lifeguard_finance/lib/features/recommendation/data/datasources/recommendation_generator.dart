import 'package:uuid/uuid.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
import '../../../literacy/data/mock_literacy_data.dart';
import '../../../literacy/domain/entities/literacy_module.dart';
import '../../domain/entities/recommendation_entity.dart';

/// Scans the FVS sub-scores (S1-S7) and produces a prioritized action plan,
/// matching the rule design from `docs/sprint_plan_steps_6_12.md` (Step 11)
/// and the task copy shown in the Stitch "Rencana Mitigasi" mockup.
class RecommendationGenerator {
  const RecommendationGenerator();

  List<Recommendation> generate(FvsScore score) {
    const uuid = Uuid();
    final tasks = <Recommendation>[];

    // S2: Rasio Pengeluaran Rutin
    if (score.s2 < 80) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Audit Pengeluaran',
        description: 'Review mutasi rekening 3 bulan terakhir dan kategorikan semua pengeluaran.',
        timeline: '30 Hari',
        priority: RecommendationPriority.high,
      ));
    }
    if (score.s2 < 60) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Potong Biaya Langganan',
        description: 'Batalkan langganan streaming dan layanan yang tidak esensial.',
        timeline: '30 Hari',
        priority: RecommendationPriority.medium,
      ));
    }

    // S3: Cakupan Dana Darurat
    if (score.s3 < 40) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Bangun Dana Darurat',
        description: 'Sisihkan 20% dari pemasukan bulan ini ke rekening terpisah.',
        timeline: '30 Hari',
        priority: RecommendationPriority.high,
      ));
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Buka Rekening Dana Darurat Terpisah',
        description: 'Pisahkan rekening tabungan utama Anda dengan rekening dana darurat instan tanpa kartu ATM untuk mencegah pembelanjaan impulsif.',
        timeline: '60 Hari',
        priority: RecommendationPriority.high,
      ));
    }

    // S4: Beban Cicilan/Utang
    if (score.s4 < 50) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Hentikan Utang Konsumtif Baru / Paylater',
        description: 'Blokir atau batasi penggunaan paylater dan kartu kredit untuk menstabilkan arus kas bulanan Anda.',
        timeline: '30 Hari',
        priority: RecommendationPriority.high,
      ));
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Lakukan Metode Pelunasan Debt Snowball',
        description: 'Susun utang berdasarkan nominal terkecil, lunasi terlebih dahulu untuk meningkatkan moral dan sisa pendapatan bebas.',
        timeline: '60 Hari',
        priority: RecommendationPriority.medium,
      ));
    }

    // S6: Kesiapan Proteksi Kesehatan
    if (score.s6 < 80) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Daftar dan Aktivasi BPJS Kesehatan Mandiri',
        description: 'Pastikan seluruh anggota keluarga terdaftar di BPJS Kesehatan untuk menghindari krisis biaya medis tak terduga.',
        timeline: '30 Hari',
        priority: RecommendationPriority.high,
      ));
    }

    // Aggressive recovery plan for Rentan/Kritis categories
    if (score.category == 'Rentan' || score.category == 'Kritis') {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Rencana Pemulihan Agresif 90 Hari',
        description:
            'Kondisi keuangan keluarga Anda berada di kategori ${score.category}. Susun ulang anggaran secara menyeluruh: pangkas pengeluaran non-esensial hingga 30%, hentikan seluruh utang konsumtif baru, dan alokasikan setiap surplus arus kas ke dana darurat selama 90 hari ke depan untuk menaikkan skor FVS ke level Waspada.',
        timeline: '90 Hari',
        priority: RecommendationPriority.high,
      ));
    }

    // Rekomendasi vault tabungan: dana darurat masih lemah
    if (score.s3 < 60) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Buat Pos Dana Darurat di Savings Vault',
        description: 'Gunakan fitur Savings Vault untuk membuat target dana darurat dengan rekomendasi setoran bulanan otomatis agar lebih disiplin menabung.',
        timeline: '60 Hari',
        priority: RecommendationPriority.medium,
        actionRoute: '/savings-vault',
      ));
    }

    // Rekomendasi modul literasi untuk indikator FVS yang paling lemah
    final weakestModule = _weakestLiteracyModule(score);
    if (weakestModule != null) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Pelajari: ${weakestModule.title}',
        description: 'Indikator "${weakestModule.relatedIndicator}" adalah titik terlemah Anda saat ini. Baca modul edukasi ini untuk memahami cara memperbaikinya.',
        timeline: '30 Hari',
        priority: RecommendationPriority.medium,
        actionRoute: '/literacy/${weakestModule.moduleId}',
      ));
    }

    if (tasks.isEmpty) {
      tasks.add(Recommendation(
        id: uuid.v4(),
        title: 'Pertahankan Kebiasaan Finansial Sehat Anda',
        description: 'Skor vitalitas finansial Anda sudah baik di semua indikator utama. Lanjutkan kebiasaan menabung dan mengelola utang secara disiplin.',
        timeline: '90 Hari',
        priority: RecommendationPriority.low,
      ));
    }

    return tasks;
  }

  /// Finds the literacy module mapped to the weakest FVS sub-indicator,
  /// or null if every indicator is already healthy (score >= 80).
  LiteracyModule? _weakestLiteracyModule(FvsScore score) {
    final indicators = {
      1: score.s1,
      2: score.s2,
      3: score.s3,
      4: score.s4,
      5: score.s5,
      6: score.s6,
      7: score.s7,
    };

    final weakestEntry = indicators.entries.reduce((a, b) => a.value <= b.value ? a : b);
    if (weakestEntry.value >= 80) return null;

    final moduleId = 'edu-s${weakestEntry.key}-1';
    final matches = mockLiteracyModules.where((m) => m.moduleId == moduleId);
    return matches.isEmpty ? null : matches.first;
  }
}
