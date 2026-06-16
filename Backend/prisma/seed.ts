import { PrismaClient, LiteracyCategory, LiteracyDifficulty } from '@prisma/client';

const prisma = new PrismaClient();

const literacyModules = [
  {
    title: 'Memahami Anggaran Pribadi',
    description: 'Pelajari dasar-dasar membuat dan mengelola anggaran pribadi yang efektif.',
    content: `# Memahami Anggaran Pribadi

Anggaran pribadi adalah fondasi kesehatan keuangan Anda. Dengan anggaran yang baik, Anda dapat mengontrol pengeluaran, menabung untuk masa depan, dan menghindari utang yang tidak perlu.

## Langkah-Langkah Membuat Anggaran

1. **Hitung Total Pendapatan**: Catat semua sumber pendapatan bulanan Anda
2. **Catat Pengeluaran Tetap**: Identifikasi pengeluaran wajib seperti sewa, utilitas, dan cicilan
3. **Alokasikan Dana**: Gunakan metode 50/30/20 - 50% kebutuhan, 30% keinginan, 20% tabungan
4. **Pantau dan Evaluasi**: Review anggaran setiap minggu

## Tips Praktis

- Gunakan aplikasi untuk mencatat pengeluaran harian
- Siapkan dana darurat minimal 3-6 bulan pengeluaran
- Evaluasi dan sesuaikan anggaran setiap bulan`,
    category: LiteracyCategory.BUDGETING,
    difficulty: LiteracyDifficulty.BEGINNER,
    duration: 10,
    order: 1,
  },
  {
    title: 'Strategi Menabung Efektif',
    description: 'Teknik-teknik menabung yang terbukti berhasil untuk mencapai tujuan keuangan.',
    content: `# Strategi Menabung Efektif

Menabung bukan soal berapa banyak yang Anda sisihkan, tapi seberapa konsisten Anda melakukannya.

## Metode Menabung

1. **Pay Yourself First**: Sisihkan tabungan sebelum membayar tagihan lain
2. **Automatic Transfer**: Atur transfer otomatis ke rekening tabungan
3. **52-Week Challenge**: Tingkatkan jumlah tabungan setiap minggu
4. **Round-Up Saving**: Bulatkan setiap transaksi dan tabung selisihnya

## Jenis Tabungan

- **Dana Darurat**: 3-6 bulan pengeluaran
- **Tabungan Tujuan**: Liburan, gadget, pendidikan
- **Investasi Jangka Panjang**: Pensiun, properti`,
    category: LiteracyCategory.SAVING,
    difficulty: LiteracyDifficulty.BEGINNER,
    duration: 8,
    order: 2,
  },
  {
    title: 'Pengantar Investasi untuk Pemula',
    description: 'Pahami konsep dasar investasi dan berbagai instrumen yang tersedia.',
    content: `# Pengantar Investasi untuk Pemula

Investasi adalah cara mengembangkan uang Anda dengan membiarkannya bekerja untuk Anda.

## Prinsip Dasar Investasi

1. **Diversifikasi**: Jangan taruh semua telur dalam satu keranjang
2. **Risk vs Return**: Semakin tinggi potensi keuntungan, semakin tinggi risikonya
3. **Time in Market**: Mulai lebih awal untuk memanfaatkan compound interest
4. **Dollar Cost Averaging**: Investasi secara rutin tanpa mempedulikan harga

## Instrumen Investasi

- **Deposito**: Risiko rendah, return terbatas
- **Obligasi**: Risiko menengah, pendapatan tetap
- **Reksa Dana**: Dikelola profesional, cocok untuk pemula
- **Saham**: Risiko tinggi, potensi return tinggi
- **Properti**: Aset riil dengan potensi apresiasi`,
    category: LiteracyCategory.INVESTING,
    difficulty: LiteracyDifficulty.BEGINNER,
    duration: 15,
    order: 3,
  },
  {
    title: 'Mengelola Utang dengan Bijak',
    description: 'Strategi untuk mengelola dan melunasi utang secara efektif.',
    content: `# Mengelola Utang dengan Bijak

Tidak semua utang itu buruk, tapi utang yang tidak terkendali bisa menghancurkan keuangan Anda.

## Jenis Utang

- **Utang Produktif**: KPR, pinjaman pendidikan, modal usaha
- **Utang Konsumtif**: Kartu kredit, pinjaman online untuk gaya hidup

## Strategi Pelunasan

1. **Debt Snowball**: Lunasi utang terkecil dulu untuk motivasi
2. **Debt Avalanche**: Lunasi utang dengan bunga tertinggi dulu untuk efisiensi
3. **Konsolidasi**: Gabungkan beberapa utang menjadi satu dengan bunga lebih rendah

## Rasio Utang Sehat

- Debt-to-Income Ratio idealnya di bawah 36%
- Cicilan maksimal 30% dari pendapatan bersih`,
    category: LiteracyCategory.DEBT_MANAGEMENT,
    difficulty: LiteracyDifficulty.INTERMEDIATE,
    duration: 12,
    order: 4,
  },
  {
    title: 'Memahami Asuransi dan Proteksi',
    description: 'Panduan lengkap tentang jenis-jenis asuransi dan pentingnya proteksi keuangan.',
    content: `# Memahami Asuransi dan Proteksi

Asuransi adalah perlindungan finansial yang melindungi Anda dari risiko tak terduga.

## Jenis Asuransi Penting

1. **Asuransi Kesehatan**: Melindungi dari biaya medis yang mahal
2. **Asuransi Jiwa**: Melindungi keluarga jika pencari nafkah meninggal
3. **Asuransi Kendaraan**: Wajib untuk pemilik kendaraan bermotor
4. **Asuransi Properti**: Melindungi aset dari bencana dan pencurian

## Tips Memilih Asuransi

- Sesuaikan dengan kebutuhan dan kemampuan
- Baca polis dengan teliti sebelum membeli
- Bandingkan beberapa provider
- Prioritaskan asuransi kesehatan dan jiwa`,
    category: LiteracyCategory.INSURANCE,
    difficulty: LiteracyDifficulty.INTERMEDIATE,
    duration: 10,
    order: 5,
  },
  {
    title: 'Perencanaan Pajak Pribadi',
    description: 'Cara memahami dan mengoptimalkan kewajiban pajak Anda.',
    content: `# Perencanaan Pajak Pribadi

Memahami pajak membantu Anda memenuhi kewajiban sekaligus mengoptimalkan keuangan.

## Dasar Pajak Penghasilan

- Penghasilan Tidak Kena Pajak (PTKP) untuk WP pribadi
- Tarif progresif berdasarkan penghasilan kena pajak
- Pelaporan SPT Tahunan setiap Maret

## Cara Mengoptimalkan Pajak

1. Manfaatkan pengurang pajak yang sah
2. Investasi di instrumen bebas pajak
3. Catat semua pengeluaran yang bisa menjadi pengurang
4. Konsultasikan dengan konsultan pajak jika diperlukan`,
    category: LiteracyCategory.TAX,
    difficulty: LiteracyDifficulty.ADVANCED,
    duration: 15,
    order: 6,
  },
  {
    title: 'Merencanakan Dana Pensiun',
    description: 'Mulai merencanakan pensiun dari sekarang untuk masa tua yang nyaman.',
    content: `# Merencanakan Dana Pensiun

Semakin dini Anda memulai, semakin mudah mencapai target dana pensiun.

## Menghitung Kebutuhan Dana Pensiun

1. Estimasi pengeluaran bulanan saat pensiun
2. Tentukan usia pensiun yang diinginkan
3. Hitung dengan memperhitungkan inflasi
4. Target: 70-80% dari gaji terakhir per bulan

## Instrumen Dana Pensiun

- BPJS Ketenagakerjaan (JHT & JP)
- DPLK (Dana Pensiun Lembaga Keuangan)
- Reksa Dana / Saham jangka panjang
- Properti untuk passive income`,
    category: LiteracyCategory.RETIREMENT,
    difficulty: LiteracyDifficulty.ADVANCED,
    duration: 12,
    order: 7,
  },
  {
    title: 'Budgeting Metode 50/30/20',
    description: 'Metode budgeting populer yang simple dan efektif untuk semua kalangan.',
    content: `# Budgeting Metode 50/30/20

Metode ini membagi pendapatan menjadi tiga kategori sederhana.

## Pembagian

- **50% Kebutuhan**: Sewa, makanan, transportasi, utilitas, asuransi
- **30% Keinginan**: Hiburan, makan di luar, hobi, belanja non-esensial
- **20% Tabungan & Investasi**: Dana darurat, tabungan, investasi, pelunasan utang

## Contoh Penerapan (Gaji 5 Juta)

| Kategori | Persentase | Jumlah |
|----------|-----------|--------|
| Kebutuhan | 50% | Rp 2.500.000 |
| Keinginan | 30% | Rp 1.500.000 |
| Tabungan | 20% | Rp 1.000.000 |

## Tips

- Fleksibel sesuaikan persentase dengan kondisi Anda
- Jika utang besar, naikkan alokasi tabungan menjadi 30%`,
    category: LiteracyCategory.BUDGETING,
    difficulty: LiteracyDifficulty.BEGINNER,
    duration: 8,
    order: 8,
  },
  {
    title: 'Reksa Dana: Investasi untuk Semua',
    description: 'Panduan lengkap memulai investasi reksa dana dari nol.',
    content: `# Reksa Dana: Investasi untuk Semua

Reksa dana adalah pilihan investasi yang cocok untuk pemula karena dikelola oleh manajer investasi profesional.

## Jenis Reksa Dana

1. **Pasar Uang**: Risiko rendah, return stabil
2. **Pendapatan Tetap**: Investasi di obligasi
3. **Campuran**: Kombinasi saham dan obligasi
4. **Saham**: Potensi return tertinggi, risiko terbesar

## Cara Memulai

1. Pilih platform investasi terpercaya (OJK-registered)
2. Tentukan profil risiko Anda
3. Mulai dengan jumlah kecil (bisa dari Rp 10.000)
4. Investasi secara rutin (Dollar Cost Averaging)
5. Evaluasi portofolio setiap 6 bulan`,
    category: LiteracyCategory.INVESTING,
    difficulty: LiteracyDifficulty.INTERMEDIATE,
    duration: 12,
    order: 9,
  },
  {
    title: 'Keuangan Sehat: Kebiasaan Harian',
    description: 'Kebiasaan harian sederhana yang berdampak besar pada kesehatan keuangan.',
    content: `# Keuangan Sehat: Kebiasaan Harian

Kesehatan keuangan dibangun dari kebiasaan kecil yang konsisten.

## 10 Kebiasaan Keuangan Sehat

1. Catat setiap pengeluaran
2. Bawa bekal makan siang
3. Tunggu 24 jam sebelum belanja impulsif
4. Review langganan bulanan yang tidak terpakai
5. Bandingkan harga sebelum membeli
6. Gunakan metode amplop untuk pengeluaran
7. Sisihkan receh dan kembalian
8. Baca satu artikel keuangan per hari
9. Diskusikan keuangan dengan pasangan
10. Review keuangan mingguan setiap Minggu malam`,
    category: LiteracyCategory.GENERAL,
    difficulty: LiteracyDifficulty.BEGINNER,
    duration: 6,
    order: 10,
  },
];

async function main() {
  console.log('🌱 Starting database seed...');

  console.log('📚 Seeding literacy modules...');
  await prisma.literacyModule.deleteMany({});
  await prisma.literacyModule.createMany({
    data: literacyModules,
    skipDuplicates: true,
  });
  console.log(`   ✅ Seeded ${literacyModules.length} literacy modules`);

  console.log('🌱 Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
