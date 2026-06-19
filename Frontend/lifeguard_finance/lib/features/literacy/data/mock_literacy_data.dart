import '../domain/entities/literacy_module.dart';

const List<LiteracyModule> mockLiteracyModules = [
  LiteracyModule(
    moduleId: 'edu-s1-1',
    title: 'Cara Menstabilkan Pendapatan Keluarga',
    topic: 'Stabilitas Pendapatan',
    relatedIndicator: 'Stabilitas Pendapatan (S1)',
    summary: 'Strategi diversifikasi sumber pendapatan agar keuangan keluarga lebih tahan terhadap goncangan.',
    content:
        'Pendapatan tunggal membuat keluarga rentan ketika sumber tersebut terganggu. Mulailah memetakan potensi pendapatan tambahan, baik dari keahlian sampingan, usaha kecil, maupun pasif income sederhana. Bangun secara bertahap tanpa mengganggu pekerjaan utama.',
    tips: 'Targetkan satu sumber pendapatan tambahan, sekecil apapun, dalam 90 hari ke depan.',
    durationMinutes: 5,
    isRecommended: true,
  ),
  LiteracyModule(
    moduleId: 'edu-s2-1',
    title: 'Mengendalikan Pengeluaran Rutin',
    topic: 'Anggaran',
    relatedIndicator: 'Rasio Pengeluaran (S2)',
    summary: 'Menerapkan formula 50-30-20 untuk membagi pendapatan bulanan secara sehat.',
    content:
        'Alokasikan 50% pendapatan untuk kebutuhan pokok, 30% untuk keinginan, dan 20% untuk tabungan/dana darurat. Catat pengeluaran harian agar pola belanja yang membengkak dapat terdeteksi sejak dini.',
    tips: 'Gunakan kategori pengeluaran dan catat setiap transaksi, sekecil apapun nilainya.',
    durationMinutes: 4,
  ),
  LiteracyModule(
    moduleId: 'edu-s3-1',
    title: 'Membangun Dana Darurat dari Nol',
    topic: 'Dana Darurat',
    relatedIndicator: 'Dana Darurat (S3)',
    summary: 'Langkah praktis menentukan dan mencapai target dana darurat keluarga.',
    content:
        'Target ideal dana darurat adalah 3-6 kali pengeluaran bulanan. Jika belum memiliki sama sekali, mulailah dengan target kecil seperti 1 bulan pengeluaran, lalu naikkan secara bertahap melalui setoran rutin otomatis.',
    tips: 'Mulai dari yang kecil — sisihkan minimal 5% pendapatan setiap bulan ke vault dana darurat.',
    durationMinutes: 5,
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: true,
  ),
  LiteracyModule(
    moduleId: 'edu-s4-1',
    title: 'Batas Aman Cicilan',
    topic: 'Manajemen Utang',
    relatedIndicator: 'Beban Utang (S4)',
    summary: 'Strategi menjaga rasio cicilan tetap di batas aman dan melunasi utang konsumtif.',
    content:
        'Idealnya total cicilan tidak melebihi 35% dari pendapatan bulanan. Jika sudah melewati batas ini, prioritaskan pelunasan utang dengan bunga tertinggi terlebih dahulu (metode avalanche) atau yang bernilai terkecil (metode snowball) untuk membangun momentum.',
    tips: 'Hindari menambah cicilan baru sebelum rasio utang berada di bawah 35%.',
    durationMinutes: 7,
    externalUrl: 'https://www.bi.go.id/id/edukasi/default.aspx',
  ),
  LiteracyModule(
    moduleId: 'edu-s5-1',
    title: 'Mengatur Beban Tanggungan Keluarga',
    topic: 'Tanggungan',
    relatedIndicator: 'Beban Tanggungan (S5)',
    summary: 'Mengelola keuangan keluarga ketika jumlah tanggungan bertambah.',
    content:
        'Setiap penambahan tanggungan perlu diiringi penyesuaian anggaran. Hitung ulang kebutuhan pokok per anggota keluarga dan pastikan pos dana darurat ikut disesuaikan agar tetap mencukupi kebutuhan seluruh anggota keluarga.',
    tips: 'Tinjau ulang anggaran keluarga setiap kali ada penambahan tanggungan baru.',
    durationMinutes: 4,
  ),
  LiteracyModule(
    moduleId: 'edu-s6-1',
    title: 'Proteksi Dasar Keluarga',
    topic: 'Proteksi',
    relatedIndicator: 'Kesiapan Proteksi (S6)',
    summary: 'Memilih proteksi BPJS dan asuransi tambahan yang tepat untuk keluarga.',
    content:
        'Proteksi dasar seperti BPJS Kesehatan adalah fondasi wajib sebelum mempertimbangkan asuransi tambahan. Asuransi jiwa dan kesehatan tambahan sebaiknya disesuaikan dengan risiko pekerjaan dan jumlah tanggungan.',
    tips: 'Pastikan status BPJS aktif sebelum menambah produk asuransi lain.',
    durationMinutes: 6,
    externalUrl: 'https://sikapiuangmu.ojk.go.id/FrontEnd/CMS/Category/132',
  ),
  LiteracyModule(
    moduleId: 'edu-s7-1',
    title: 'Bertahan Saat Pendapatan Utama Berhenti',
    topic: 'Daya Tahan Krisis',
    relatedIndicator: 'Daya Tahan Kejutan (S7)',
    summary: 'Langkah-langkah darurat ketika sumber pendapatan utama keluarga terhenti.',
    content:
        'Segera lakukan audit pengeluaran dan pangkas pos non-esensial. Aktifkan dana darurat sesuai prioritas kebutuhan pokok, lalu cari sumber pendapatan sementara secepat mungkin sambil menjaga komunikasi terbuka dengan seluruh anggota keluarga.',
    tips: 'Siapkan daftar pengeluaran yang bisa dipangkas dalam 24 jam sejak kehilangan pendapatan.',
    durationMinutes: 6,
  ),
];
