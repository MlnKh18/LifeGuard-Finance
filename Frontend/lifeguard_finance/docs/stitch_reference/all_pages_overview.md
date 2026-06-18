# 📱 Panduan Katalog & Spesifikasi Halaman LifeGuard Finance

Dokumen ini menyediakan spesifikasi teknis lengkap antarmuka (UI/UX) untuk seluruh **9 Halaman utama** aplikasi **LifeGuard Finance**. Setiap halaman dideskripsikan secara mendalam mencakup tujuan, struktur tata letak, elemen antarmuka, status state, dan aturan desain token yang diterapkan.

---

## 🎨 Token Desain Global (Referensi Cepat)
*   **Tema**: Premium Dark Slate
*   **Latar Belakang**: `background` (`#0F172A`)
*   **Permukaan**: `surface` (`#1E293B`)
*   **Warna Primer**: `primary` (`#1E3A8A`) | `primaryLight` (`#3B82F6`)
*   **Warna Aksen**: `accent` (`#0D9488` - Toska)
*   **Indikator Skor**: 🟢 Aman ($\ge 70$), 🟡 Waspada ($55-69$), 🟠 Rentan ($40-54$), 🔴 Kritis ($< 40$).
*   **Sudut Lengkungan**: `16.0` (`AppStyles.radiusMedium` / `BorderRadius.circular(16)`)

---

## 🗂️ Daftar Halaman Aplikasi

### 1. Splash Screen (`SplashScreen`)
*   **Tujuan**: Halaman branding pembuka untuk memperkenalkan identitas LifeGuard Finance kepada pengguna baru.
*   **Struktur Tata Letak**:
    *   **Header**: Area kosong (*Spacer*).
    *   **Body**: Logo perisai keselamatan di bagian tengah vertikal, disusul judul aplikasi dan deskripsi misi.
    *   **Footer**: Ringkasan badge fitur, tombol CTA utama, dan baris disclaimer lisensi hukum.
*   **Elemen UI & Komponen**:
    *   `Icon(LucideIcons.shieldAlert)` berukuran 72pt berwarna putih di dalam container lingkaran semi-transparan.
    *   Teks Judul `"LifeGuard Finance"` berukuran 34pt, tebal (bold), warna putih bersih.
    *   Teks Sub-deskripsi `"Deteksi Risiko Finansial Keluarga Sebelum Krisis Terjadi"`.
    *   Feature Badges: Row horizontal dengan 3 ikon mini (`activity` - Detect FVS, `flaskConical` - Simulate, `compass` - Guide).
    *   Button CTA: `ElevatedButton` berlatar putih dengan teks utama oranye/biru gelap untuk kontras tinggi.
*   **State & Interaksi**:
    *   **Pemicu**: Navigasi sekali jalan (*Push Replacement*) ke `OnboardingScreen` saat tombol CTA ditekan.
    *   **Animasi**: Transisi masuk menggunakan `flutter_animate` (scale bounce pada perisai, slide-up fade-in pada teks).

---

### 2. Onboarding Wizard Form (`OnboardingScreen`)
*   **Tujuan**: Mengumpulkan data finansial keluarga awal melalui antarmuka langkah-demi-langkah (wizard) untuk menghitung profil risiko pertama kali.
*   **Struktur Tata Letak**:
    *   **Header**: Indikator progres langkah (*Stepper Indicator*) 3 bagian.
    *   **Body**: Formulir input bergulir (*Scrollable Form*) yang dikelompokkan berdasarkan kategori data.
    *   **Footer**: Row tombol navigasi ("Kembali" di kiri, "Lanjut/Simpan" di kanan).
*   **Elemen UI & Komponen**:
    *   **Langkah 1 (Biodata & Pendapatan)**:
        *   `TextFormField` untuk Nama Keluarga (dengan dekorasi input premium).
        *   `TextFormField` untuk Jumlah Tanggungan (input numerik).
        *   `TextFormField` untuk Pendapatan Bulanan (formatted currency placeholder).
        *   `DropdownButtonFormField` Kestabilan Pendapatan (Pilihan: Stabil, Semi-Stabil, Fluktuatif).
    *   **Langkah 2 (Pengeluaran & Hutang)**:
        *   `TextFormField` Pengeluaran Rutin Bulanan.
        *   `TextFormField` Cicilan Bulanan Aktif.
        *   `TextFormField` Total Saldo Hutang.
    *   **Langkah 3 (Aset & Asuransi)**:
        *   `TextFormField` Saldo Dana Darurat Saat Ini.
        *   `TextFormField` Total Aset Likuid (Tabungan, Reksadana Pasar Uang).
        *   `TextFormField` Total Aset Non-Likuid (Rumah, Tanah, Kendaraan).
        *   `DropdownButtonFormField` Kesiapan Proteksi / Asuransi (Pilihan: Penuh, Parsial, Tidak Ada).
*   **State & Interaksi**:
    *   Menggunakan `PageController` untuk transisi horizontal antar formulir.
    *   Riverpod State: Menyimpan data yang diinput ke `profileStateProvider`, yang otomatis memicu perhitungan FVS pertama di `fvsStateProvider`.
    *   Navigasi: Mengarahkan pengguna langsung ke `MainNavigation` (Dashboard) setelah menyimpan data langkah ke-3.

---

### 3. Dashboard Utama (`DashboardScreen`)
*   **Tujuan**: Pusat pemantauan kesehatan keuangan keluarga yang menyajikan skor FVS total beserta indikator pilar.
*   **Struktur Tata Letak**:
    *   **Header**: Bar sapaan pengguna dinamis dan ikon lonceng notifikasi (dilengkapi badge merah jumlah peringatan aktif).
    *   **Body (Scrollable)**:
        *   Banner Peringatan Dini (hanya muncul jika terdapat indikator berstatus Kritis/Rentan).
        *   Grafik Setengah Lingkaran (`CircularGauge`) FVS Score.
        *   Grid/Daftar Kartu Indikator Detail (7 pilar penilaian).
*   **Elemen UI & Komponen**:
    *   `CircularGauge`: Widget kustom dengan jarum penunjuk skor dan gradasi melengkung sewarna status FVS (hijau/kuning/oranye/merah).
    *   `EarlyWarningBanner`: Kotak merah transparan berisi ringkasan krisis terdeteksi yang dapat diklik untuk detail mitigasi.
    *   `IndicatorCard`: Kartu data dengan ikon pilar, nama indikator, nilai numerik skor (0-100), label verbal (Aman/Waspada/Rentan/Kritis), dan bar kemajuan linear (*LinearProgressIndicator*).
*   **State & Interaksi**:
    *   Riverpod Watch: `profileStateProvider` (memantau profil finansial), `fvsStateProvider` (skor FVS terhitung), `notificationsProvider` (daftar notifikasi peringatan).
    *   Aksi: Mengklik `IndicatorCard` memicu pembukaan `showModalBottomSheet` yang menampilkan rumus rule-based dan tips mitigasi preventif.

---

### 4. Simulasi Krisis Finansial (`SimulationScreen`)
*   **Tujuan**: Ruang uji coba skenario (sandbox) untuk memproyeksikan kekuatan keuangan keluarga saat menghadapi krisis mendadak.
*   **Struktur Tata Letak**:
    *   **Header**: Judul modul dan dropdown pemilihan skenario krisis.
    *   **Body**: Panel kontrol slider parameter krisis dan perbandingan hasil skor sebelum vs sesudah krisis.
    *   **Footer**: Tombol simpan hasil simulasi ke riwayat.
*   **Elemen UI & Komponen**:
    *   `DropdownButton`: Memilih skenario (1. PHK/Kehilangan Kerja, 2. Kenaikan Suku Bunga KPR & Inflasi, 3. Krisis Medis Darurat).
    *   `Slider`: Pengaturan durasi menganggur (1-12 bulan) atau persentase lonjakan inflasi (1%-20%).
    *   `ComparisonCard`: Kartu kembar bersebelahan yang menampilkan Skor FVS Saat Ini (kiri) dan Skor Proyeksi (kanan) dipisahkan oleh ikon panah kanan (`Icons.arrow_forward`).
    *   Teks penjelasan rekomendasi taktis hasil simulasi.
*   **State & Interaksi**:
    *   Menggunakan state lokal untuk menghitung perubahan skor dinamis saat slider digeser (rule-based simulation engine).
    *   Tombol "Simpan Simulasi" menyimpan skenario ke riwayat lokal melalui database SQLite.

---

### 5. Pos Dana Darurat / Tabung (`VaultScreen`)
*   **Tujuan**: Mengelola alokasi dana darurat yang diisolasi ke dalam pos-pos target khusus (misal: Pos Medis, Pos PHK, Pos Sekolah Anak).
*   **Struktur Tata Letak**:
    *   **Header**: Ringkasan akumulasi dana terkumpul dari seluruh pos terdaftar.
    *   **Body**: Grid/Daftar kartu pos tabungan mandiri.
    *   **Footer**: Tombol melayang (*Floating Action Button*) atau tombol bawah untuk menambah pos vault baru.
*   **Elemen UI & Komponen**:
    *   `VaultCard`: Menampilkan nama pos, ikon tujuan, nominal terkumpul dibanding target (`Rp 15.000.000 / Rp 20.000.000`), bar persentase target melingkar (*CircularProgressIndicator*), dan tombol aksi cepat "+ Tabung".
    *   `AddVaultDialog`: Formulir dialog input nama pos, target nominal, prioritas (Tinggi/Sedang/Rendah), dan setoran awal.
*   **State & Interaksi**:
    *   Riverpod Watch: `vaultsProvider` (mengawasi daftar pos dari database).
    *   Interaksi: Tombol "+ Tabung" memicu dialog input nominal tambah dana yang secara instan memperbarui persentase progress pos tabungan.

---

### 6. Deteksi Anomali Pengeluaran (`InsightsScreen`)
*   **Tujuan**: Membantu pengguna memantau pengeluaran bulanan dan mendeteksi secara otomatis lonjakan pengeluaran kategori tidak wajar (anomali) dibanding rata-rata pengeluaran historis.
*   **Struktur Tata Letak**:
    *   **Header**: Grafik garis tren pengeluaran kategori.
    *   **Body**: Daftar transaksi bulanan dan penanda visual anomali.
    *   **Footer**: Tombol melayang untuk mencatat pengeluaran baru.
*   **Elemen UI & Komponen**:
    *   `LineChart` (`fl_chart`): Grafik visualisasi pengeluaran bulanan.
    *   `ExpenseTile`: ListTile berisi ikon kategori, nominal transaksi, tanggal pencatatan, dan label penanda khusus `"ANOMALI (HIGH)"` berwarna merah terang apabila melampaui batas wajar 160% dari rata-rata.
    *   `AddExpenseDialog`: Form input kategori, nominal, tanggal, dan switch toggle apakah pengeluaran bersifat rutin atau tidak rutin.
*   **State & Interaksi**:
    *   Riverpod Watch: `expensesProvider` (daftar transaksi pengeluaran).
    *   Logika Bisnis: Menyimpan transaksi baru memicu pencocokan rata-rata kategori historis. Jika nominal melampaui batas toleransi, status anomali diatur menjadi true dan memicu pengiriman notifikasi peringatan baru ke `notificationsProvider`.

---

### 7. Komunitas & Tantangan (`CommunityScreen`)
*   **Tujuan**: Ruang berbagi tips keuangan keluarga antar pengguna, diskusi generasi sandwich, serta sistem gamifikasi keaktifan pengguna (XP & Badge).
*   **Struktur Tata Letak**:
    *   **Header**: Kartu informasi poin XP, level badge pengguna saat ini, dan status tantangan mingguan.
    *   **Body**: Feed postingan diskusi forum secara vertikal.
    *   **Footer**: Tombol tulis pertanyaan baru.
*   **Elemen UI & Komponen**:
    *   `LeaderboardCard`: Kartu profil pengguna berisi jumlah XP (misal: `135 XP`), dan badge level (`Sersan Finansial` / `Pahlawan Finansial Keluarga`).
    *   `PostTile`: Kartu postingan forum berisi nama penulis, tag kategori topik (`#SandwichGeneration`, `#DanaDarurat`), isi tulisan singkat, tombol dukung pertanyaan ("+1 Dukungan"), dan jumlah komentar.
    *   `ChallengeTile`: Daftar tantangan mingguan (misal: "Catat pengeluaran rutin selama 7 hari berturut-turut untuk mendapatkan +20 XP").
*   **State & Interaksi**:
    *   Riverpod Watch: `communityProvider` (daftar post forum), `rewardPointsProvider` (menyimpan akumulasi poin XP dan badge level).
    *   Aksi: Mengklik tombol "+1 Dukungan" menambahkan dukungan pada postingan dan memberikan tambahan poin XP langsung kepada penulis secara dinamis.

---

### 8. Rencana Aksi Checklist (`ActionPlanScreen`)
*   **Tujuan**: Menyediakan checklist rencana aksi taktis mitigasi risiko keuangan jangka pendek (30 Hari), jangka menengah (60 Hari), dan jangka panjang (90 Hari).
*   **Struktur Tata Letak**:
    *   **Header**: Ringkasan progres checklist terselesaikan (`7 / 12 Aksi Selesai`).
    *   **Body**: Navigasi tab periode waktu (30 Hari / 60 Hari / 90 Hari) yang berisi daftar item checklist aksi.
*   **Elemen UI & Komponen**:
    *   `TabBar` / `TabBarView`: Tab interaktif 30, 60, dan 90 hari.
    *   `ChecklistTile`: Item checkbox interaktif yang dicentang. Deskripsi aksi ditulis dalam layout premium. Jika status selesai, deskripsi mengalami coret tengah (*strike-through*) dan warna meredup.
    *   `AddCustomActionDialog`: Memungkinkan pengguna menambahkan aksi kustom personal di luar rekomendasi sistem.
*   **State & Interaksi**:
    *   Daftar aksi dinonaktifkan/diaktifkan berdasarkan skor pilar terendah pengguna. State tersimpan secara persisten sehingga status centang tetap terjaga ketika aplikasi ditutup dan dibuka kembali.

---

### 9. Pengaturan & Privasi (`SettingsScreen`)
*   **Tujuan**: Panel kontrol aplikasi, pembaruan profil keuangan, pengaturan keamanan PIN, dan pembersihan basis data lokal.
*   **Elemen UI & Komponen**:
    *   `ProfileSummaryTile`: Kartu profil singkat pengguna berisi nama keluarga dan tombol edit profil (memicu pembukaan wizard onboarding untuk pengisian ulang).
    *   `SwitchListTile` PIN Security: Mengaktifkan/menonaktifkan kunci PIN biometrik saat aplikasi dibuka.
    *   `ListTile` Reset Data: Tombol merah menyala bertuliskan "Hapus Seluruh Data Aplikasi" untuk mereset seluruh database SQLite dan state Riverpod kembali ke kondisi kosong (dilengkapi dialog konfirmasi ganda).
*   **State & Interaksi**:
    *   Riverpod Watch: `profileStateProvider` untuk memantau keberadaan data profil.
    *   Metode reset: Menggunakan provider `databaseResetProvider` untuk menghapus basis data SQLite secara asinkronus dan mengatur ulang semua state provider Riverpod.

---
> [!TIP]
> **Catatan Implementasi Frontend**:
> Semua halaman di atas dirancang responsif mengikuti layout grid vertikal dengan padding horizontal standar sebesar `16.0` (`AppStyles.l`).
> Gunakan `IndexedStack` untuk navigasi antar screen pilar (Dashboard, Vault, Insights, Community) agar data input/scroll state pada masing-masing halaman tidak ter-reset saat berpindah tab.
