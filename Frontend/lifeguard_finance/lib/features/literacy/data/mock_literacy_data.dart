import '../domain/entities/literacy_module.dart';

final List<LiteracyModule> seedLiteracyModules = [
  LiteracyModule(
    moduleId: 's1-income-stability',
    title: 'Menjaga Stabilitas Pendapatan Keluarga',
    topic: 'Stabilitas Pendapatan',
    relatedIndicator: 'S1',
    relatedIndicatorLabel: 'Income Stability',
    summary: 'Edukasi tentang pentingnya kemampuan memenuhi kebutuhan dasar, memantau arus kas, dan mendiversifikasi tabungan.',
    content: '''Pendapatan yang stabil adalah fondasi utama keuangan keluarga. Tanpa pendapatan yang stabil, rencana keuangan jangka panjang tidak bisa berjalan dengan baik. Otoritas Jasa Keuangan (OJK) menekankan pentingnya keluarga memiliki kemampuan untuk memenuhi kebutuhan dasar, menabung, dan mengantisipasi risiko keuangan.

Selalu catat dan pantau seluruh pemasukan serta pengeluaran bulanan. Bedakan kebutuhan dan keinginan dengan membuat skala prioritas agar pengeluaran fokus pada kebutuhan wajib (seperti makan, tagihan listrik/air, transportasi) sebelum dialokasikan ke hal lain.

Selain itu, OJK sering menyarankan metode pembagian pendapatan yang proporsional, seperti pola 10-20-30-40:
- 10% untuk Biaya Sosial
- 20% untuk Tabungan/Investasi/Proteksi
- 30% untuk Cicilan Utang
- 40% untuk Biaya Rumah Tangga''',
    keyTakeaways: [
      'Stabilitas pendapatan adalah pondasi keuangan.',
      'Pisahkan kebutuhan wajib dari keinginan.',
      'Gunakan rumus alokasi pendapatan seperti 10-20-30-40.',
    ],
    practicalTips: [
      'Catat setiap pemasukan dan pengeluaran.',
      'Evaluasi pengeluaran setiap bulan.',
      'Cari sumber pendapatan tambahan yang legal.',
    ],
    durationMinutes: 4,
    sourceName: 'OJK Sikapi Uangmu',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  LiteracyModule(
    moduleId: 's2-expense-ratio',
    title: 'Mengatur Pengeluaran agar Tidak Melebihi Kemampuan',
    topic: 'Manajemen Pengeluaran',
    relatedIndicator: 'S2',
    relatedIndicatorLabel: 'Expense Ratio',
    summary: 'Prinsip penyusunan prioritas (kebutuhan vs keinginan) dan pentingnya mencatat pemasukan dan pengeluaran.',
    content: '''Berdasarkan panduan dari Otoritas Jasa Keuangan (OJK), mengatur pengeluaran keluarga merupakan langkah krusial untuk mencapai stabilitas finansial.

Tentukan tujuan keuangan jangka pendek, menengah, dan panjang bersama pasangan. Catat semua pendapatan dan pengeluaran menggunakan buku catatan atau aplikasi keuangan digital. Evaluasi kondisi keuangan secara berkala.

Prioritaskan kebutuhan pokok di atas gaya hidup. Anda bisa merujuk pada pedoman alokasi, misalnya: 49% untuk kebutuhan hidup, 30% untuk cicilan utang, 20% untuk tabungan dan investasi, serta 10% untuk asuransi atau dana darurat.''',
    keyTakeaways: [
      'Pengeluaran tidak boleh lebih besar dari pendapatan.',
      'Catat pengeluaran secara konsisten.',
      'Diskusikan anggaran bersama pasangan.',
    ],
    practicalTips: [
      'Gunakan aplikasi pencatat keuangan.',
      'Hindari belanja impulsif.',
      'Batasi pengeluaran konsumtif maksimal 30% jika memungkinkan.',
    ],
    durationMinutes: 5,
    sourceName: 'OJK Sikapi Uangmu',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  LiteracyModule(
    moduleId: 's3-emergency-fund',
    title: 'Membangun Dana Darurat Keluarga',
    topic: 'Dana Darurat',
    relatedIndicator: 'S3',
    relatedIndicatorLabel: 'Emergency Fund Coverage',
    summary: 'Fungsi dana darurat sebagai jaring pengaman untuk menghindari jeratan utang, dengan target ideal 3-12 bulan pengeluaran.',
    content: '''Dana darurat adalah simpanan uang yang dipersiapkan secara khusus untuk menghadapi situasi mendesak atau pengeluaran tidak terduga, seperti kehilangan pekerjaan, biaya medis mendadak, atau perbaikan rumah/kendaraan.

Manfaat utama dana darurat adalah sebagai "jaring pengaman" finansial agar tabungan investasi jangka panjang tidak terganggu, serta menghindarkan Anda dari utang.

Besaran dana darurat yang ideal:
- Lajang: 3–6 kali pengeluaran bulanan.
- Menikah/Berkeluarga: 6–12 kali pengeluaran bulanan.

Simpan dana darurat di instrumen yang aman dan mudah dicairkan seperti Rekening Tabungan, Deposito Berjangka, atau Reksa Dana Pasar Uang.''',
    keyTakeaways: [
      'Dana darurat melindungi dari utang mendadak.',
      'Target untuk keluarga adalah 6-12 kali pengeluaran bulanan.',
      'Simpan di instrumen yang aman dan likuid.',
    ],
    practicalTips: [
      'Pisahkan rekening dana darurat dari rekening harian.',
      'Sisihkan dana di awal bulan, jangan menunggu sisa.',
      'Evaluasi target dana darurat setahun sekali.',
    ],
    durationMinutes: 6,
    sourceName: 'OJK Sikapi Uangmu',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  LiteracyModule(
    moduleId: 's4-debt-burden',
    title: 'Menjaga Cicilan agar Tetap Sehat',
    topic: 'Manajemen Utang',
    relatedIndicator: 'S4',
    relatedIndicatorLabel: 'Debt Burden Ratio',
    summary: 'Pentingnya menjaga Rasio Utang maksimal 30% dari pendapatan dan dampaknya terhadap SLIK OJK.',
    content: '''Dalam pengelolaan keuangan pribadi, OJK menggunakan Debt Service Ratio (DSR) atau Rasio Utang terhadap Pendapatan untuk menilai kesehatan utang seseorang.

Pakar keuangan menyarankan agar total cicilan bulanan tidak melebihi 30% dari total pendapatan bulanan. Misalnya, jika penghasilan Anda Rp10 juta, total cicilan tidak boleh lebih dari Rp3 juta.

Rasio ini penting karena menjadi indikator kemampuan bayar Anda tanpa mengorbankan kebutuhan sehari-hari, serta memengaruhi penilaian kredit (BI Checking/SLIK). Bedakan antara utang produktif (KPR, modal usaha) dan utang konsumtif.''',
    keyTakeaways: [
      'Batas aman cicilan utang adalah 30% dari pendapatan.',
      'Utang konsumtif harus diminimalkan.',
      'SLIK OJK memantau kelancaran pembayaran utang.',
    ],
    practicalTips: [
      'Hitung total cicilan bulanan Anda saat ini.',
      'Jangan mengambil utang baru jika rasio sudah di atas 30%.',
      'Lunasi utang dengan bunga terbesar lebih dulu.',
    ],
    durationMinutes: 5,
    sourceName: 'Bank Indonesia & OJK',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  LiteracyModule(
    moduleId: 's5-dependent-load',
    title: 'Mengelola Keuangan dengan Banyak Tanggungan',
    topic: 'Generasi Sandwich',
    relatedIndicator: 'S5',
    relatedIndicatorLabel: 'Dependent Load',
    summary: 'Strategi finansial untuk generasi sandwich, perlindungan hari tua, dan membuat pos dana terpisah.',
    content: '''Bagi Generasi Sandwich yang menanggung orang tua dan anak-anak, perencanaan yang disiplin dan komunikasi terbuka sangat penting.

Langkah pertama adalah inventarisasi aset dan utang untuk menentukan batas kemampuan finansial. Jangan memendam masalah keuangan sendirian, komunikasikan dengan pasangan dan orang tua mengenai batasan kemampuan Anda.

Selain itu, pastikan memiliki asuransi kesehatan yang memadai bagi seluruh anggota keluarga dan mulailah mencicil dana pensiun Anda sendiri untuk memutus mata rantai generasi sandwich di masa depan.''',
    keyTakeaways: [
      'Komunikasi terbuka adalah kunci mengelola tanggungan.',
      'Pisahkan pos keuangan untuk orang tua dan keluarga inti.',
      'Persiapkan dana pensiun untuk memutus rantai sandwich.',
    ],
    practicalTips: [
      'Buat tabungan rencana terpisah untuk dana pendidikan dan dana bantuan orang tua.',
      'Pastikan orang tua tercover asuransi kesehatan (BPJS).',
      'Belajar berkata "tidak" untuk pengeluaran di luar prioritas.',
    ],
    durationMinutes: 7,
    sourceName: 'OJK Sikapi Uangmu',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  LiteracyModule(
    moduleId: 's6-protection-readiness',
    title: 'Proteksi Dasar untuk Keluarga',
    topic: 'Asuransi dan Proteksi',
    relatedIndicator: 'S6',
    relatedIndicatorLabel: 'Protection Readiness',
    summary: 'Perbedaan asuransi jiwa untuk pencari nafkah dan asuransi kesehatan untuk mitigasi biaya medis tinggi.',
    content: '''Proteksi keuangan berfungsi sebagai "perisai" untuk menjaga stabilitas ekonomi keluarga agar rencana keuangan jangka panjang tidak hancur saat musibah datang.

Menabung saja tidak cukup untuk menghadapi risiko katastrofik seperti sakit kritis atau meninggalnya pencari nafkah. Oleh karena itu, OJK menyarankan keluarga untuk memiliki asuransi dasar:
1. Asuransi Jiwa: Wajib bagi pencari nafkah utama untuk melindungi ahli waris jika terjadi risiko meninggal dunia.
2. Asuransi Kesehatan: Mencegah tabungan terkuras karena tingginya biaya perawatan medis.''',
    keyTakeaways: [
      'Menabung saja tidak cukup untuk perlindungan risiko besar.',
      'Pencari nafkah wajib memiliki asuransi jiwa.',
      'Asuransi kesehatan melindungi tabungan keluarga.',
    ],
    practicalTips: [
      'Daftarkan seluruh anggota keluarga ke BPJS Kesehatan.',
      'Hitung Uang Pertanggungan Asuransi Jiwa minimal sebesar 5 tahun pengeluaran keluarga.',
      'Beli asuransi murni (term life) jika anggaran terbatas.',
    ],
    durationMinutes: 6,
    sourceName: 'OJK Sikapi Uangmu',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  LiteracyModule(
    moduleId: 's7-shock-absorption',
    title: 'Menyiapkan Keluarga Menghadapi Guncangan Finansial',
    topic: 'Ketahanan Finansial',
    relatedIndicator: 'S7',
    relatedIndicatorLabel: 'Shock Absorption Capacity',
    summary: 'Strategi mengalokasikan kelebihan dana untuk investasi, melunasi utang, dan menggabungkan proteksi dengan dana darurat.',
    content: '''Dalam menghadapi guncangan finansial, OJK menekankan pentingnya pengelolaan keuangan keluarga yang tertib, terencana, dan memiliki proteksi yang memadai.

Jika Anda memiliki sisa dana, gunakan untuk:
1. Membayar lunas utang konsumtif untuk meringankan beban masa depan.
2. Mempertebal Dana Darurat di instrumen likuid.
3. Berinvestasi pada platform legal dan terdaftar di OJK.

Keluarga yang tahan banting adalah yang memiliki bantalan kas yang kuat (Dana Darurat), lindung nilai (Asuransi), serta utang yang terkontrol dengan baik.''',
    keyTakeaways: [
      'Ketahanan finansial diukur dari seberapa lama keluarga bisa bertahan saat krisis.',
      'Dana darurat dan asuransi adalah pondasi ketahanan.',
      'Hanya berinvestasi pada platform legal OJK.',
    ],
    practicalTips: [
      'Lunasi segera utang kartu kredit dan pinjol.',
      'Cek legalitas investasi di kontak OJK 157.',
      'Biasakan hidup di bawah kemampuan (living below your means).',
    ],
    durationMinutes: 5,
    sourceName: 'OJK Sikapi Uangmu',
    externalUrl: 'https://sikapiuangmu.ojk.go.id/',
    isRecommended: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  )
];
