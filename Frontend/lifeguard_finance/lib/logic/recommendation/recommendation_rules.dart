import '../../data/models/finance_profile.dart';
import '../../data/models/fvs_score.dart';
import '../../data/models/recommendation.dart';

class RecommendationRules {
  /// Generates a list of actionable recommendations based on profile and scores
  static List<Recommendation> generate({
    required FamilyFinanceProfile profile,
    required FVSScore score,
  }) {
    final List<Recommendation> list = [];

    // 1. Emergency Fund recommendations (Primary Shock Absorber)
    if (score.emergencyFundScore < 75) {
      list.add(Recommendation(
        title: 'Mulai Rekening Dana Darurat Terpisah',
        recommendationText: 'Buat rekening bank tanpa biaya admin bulanan khusus untuk dana darurat. Jangan gabung dengan rekening operasional harian.',
        priorityLevel: score.emergencyFundScore < 40 ? 'Tinggi' : 'Sedang',
        actionPeriod: '30 Hari',
        category: 'Dana Darurat',
      ));
      
      list.add(Recommendation(
        title: 'Kumpulkan Target Darurat Tahap 1',
        recommendationText: 'Fokus mengumpulkan minimal 1 kali nilai pengeluaran bulanan esensial keluarga terlebih dahulu.',
        priorityLevel: score.emergencyFundScore < 40 ? 'Tinggi' : 'Sedang',
        actionPeriod: '60 Hari',
        category: 'Dana Darurat',
      ));
      
      list.add(Recommendation(
        title: 'Potong Pengeluaran Non-Esensial 15%',
        recommendationText: 'Kurangi biaya makan di luar, belanja fashion, atau hiburan untuk dialokasikan langsung mempertebal dana darurat keluarga.',
        priorityLevel: 'Sedang',
        actionPeriod: '90 Hari',
        category: 'Dana Darurat',
      ));
    }

    // 2. Debt Burden recommendations
    if (score.debtBurdenScore < 80) {
      list.add(Recommendation(
        title: 'Moratorium Utang Baru & Paylater',
        recommendationText: 'Stop membuat utang konsumtif baru, termasuk penggunaan paylater dan cicilan kartu kredit tanpa bunga.',
        priorityLevel: score.debtBurdenScore < 40 ? 'Tinggi' : 'Sedang',
        actionPeriod: '30 Hari',
        category: 'Utang',
      ));
      
      list.add(Recommendation(
        title: 'Terapkan Strategi Debt Snowball',
        recommendationText: 'Urutkan utang dari nominal terkecil dan bayar secepat mungkin selagi membayar pembayaran minimum utang lainnya.',
        priorityLevel: 'Sedang',
        actionPeriod: '60 Hari',
        category: 'Utang',
      ));
      
      list.add(Recommendation(
        title: 'Konsolidasi & Restrukturisasi Utang',
        recommendationText: 'Hubungi pemberi pinjaman untuk menegosiasikan penurunan bunga atau perpanjangan tenor agar cicilan bulanan di bawah 30% pendapatan.',
        priorityLevel: score.debtBurdenScore < 40 ? 'Tinggi' : 'Sedang',
        actionPeriod: '90 Hari',
        category: 'Utang',
      ));
    }

    // 3. Expense & Budgeting recommendations
    if (score.expenseRatioScore < 80) {
      list.add(Recommendation(
        title: 'Catat Seluruh Pengeluaran Harian',
        recommendationText: 'Lakukan audit dan catat setiap rupiah pengeluaran keluarga selama 30 hari ke depan untuk melihat kebocoran keuangan.',
        priorityLevel: 'Sedang',
        actionPeriod: '30 Hari',
        category: 'Pengeluaran',
      ));
      
      list.add(Recommendation(
        title: 'Terapkan Metode Anggaran 50/30/20',
        recommendationText: 'Alokasikan pendapatan bersih bulanan: 50% kebutuhan pokok, 30% keinginan pribadi, dan minimal 20% untuk tabungan/investasi.',
        priorityLevel: 'Sedang',
        actionPeriod: '60 Hari',
        category: 'Pengeluaran',
      ));
      
      list.add(Recommendation(
        title: 'Batalkan Langganan Digital yang Jarang Dipakai',
        recommendationText: 'Tinjau kembali pengeluaran langganan seperti streaming video, musik, aplikasi, atau membership gym yang tidak produktif.',
        priorityLevel: 'Rendah',
        actionPeriod: '90 Hari',
        category: 'Pengeluaran',
      ));
    }

    // 4. Protection (BPJS/Asuransi) recommendations
    if (score.protectionReadinessScore < 100) {
      if (!profile.hasHealthProtection) {
        list.add(Recommendation(
          title: 'Daftarkan BPJS Kesehatan Seluruh Anggota Keluarga',
          recommendationText: 'Langkah perlindungan medis paling mendesak. Segera daftarkan keluarga ke BPJS Kesehatan mandiri kelas 2/3.',
          priorityLevel: 'Tinggi',
          actionPeriod: '30 Hari',
          category: 'Proteksi',
        ));
      }
      
      if (!profile.hasLifeProtection && profile.dependentsCount > 0) {
        list.add(Recommendation(
          title: 'Pelajari Asuransi Jiwa Berjangka (Term Life)',
          recommendationText: 'Cari asuransi jiwa berjangka murni tanpa unsur investasi (unit link) dengan nilai premi di bawah Rp 150rb per bulan.',
          priorityLevel: 'Sedang',
          actionPeriod: '60 Hari',
          category: 'Proteksi',
        ));
      }

      list.add(Recommendation(
        title: 'Pastikan Polis Proteksi Tetap Aktif',
        recommendationText: 'Setel pembayaran autodebet untuk iuran BPJS Kesehatan atau premi asuransi agar status perlindungan tidak mati saat darurat.',
        priorityLevel: 'Sedang',
        actionPeriod: '90 Hari',
        category: 'Proteksi',
      ));
    }

    // Fallback if family is already very secure (high score)
    if (list.isEmpty) {
      list.add(Recommendation(
        title: 'Pertahankan Disiplin Keuangan',
        recommendationText: 'Kondisi finansial Anda luar biasa aman. Teruskan alokasi tabungan bulanan secara otomatis.',
        priorityLevel: 'Rendah',
        actionPeriod: '30 Hari',
        category: 'Dana Darurat',
      ));
      list.add(Recommendation(
        title: 'Optimalkan Dana Darurat di RDP',
        recommendationText: 'Pindahkan sebagian dana darurat yang melebihi kebutuhan 3 bulan ke Reksadana Pasar Uang (RDP) agar tumbuh di atas inflasi.',
        priorityLevel: 'Rendah',
        actionPeriod: '60 Hari',
        category: 'Dana Darurat',
      ));
    }

    return list;
  }
}
