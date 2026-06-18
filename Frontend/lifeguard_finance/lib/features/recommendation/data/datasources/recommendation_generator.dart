import 'package:uuid/uuid.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
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
}
