# Step 18 — Testing, UI Polish, dan Build APK

Dokumen ini adalah deliverable Step 18 dari `docs/steps.md`: checklist testing,
command terminal, checklist UI polish, checklist build APK, dan urutan demo
pitch untuk LifeGuard Finance.

## 1. Automated tests yang sudah dibuat

| File | Target |
| --- | --- |
| `test/features/fvs_dashboard/fvs_calculator_test.dart` | Unit test `FvsCalculator` (formula bobot S1-S7, kategori Aman/Waspada/Rentan/Kritis, edge case income = 0) |
| `test/features/emergency_simulation/simulation_calculator_test.dart` | Unit test `SimulationCalculator` (6 skenario: PHK, medis, kenaikan cicilan, inflasi, pendidikan, tambah tanggungan) |
| `test/features/smart_routing/smart_routing_calculator_test.dart` | Unit test `SmartRoutingCalculator` (alokasi 4 kategori FVS selalu total 100%) |
| `test/features/anomaly_detection/anomaly_detection_service_test.dart` | Unit test `AnomalyDetectionService` (rule >30% Ringan, >50% Tinggi, normal, kategori tanpa histori) |
| `test/features/fvs_dashboard/fvs_bloc_test.dart` | Bloc test `FvsBloc` (LoadFvs, CalculateFvs, snapshot skor sebelumnya, error handling) |
| `test/features/family_profile/family_profile_bloc_test.dart` | Bloc test `FamilyProfileBloc` (load & save, sukses dan gagal) |
| `test/features/fvs_dashboard/dashboard_page_test.dart` | Widget test `DashboardView` (loading state, no-profile state, error state) |

Semua file di atas sudah dijalankan dan **lulus** (`flutter test` → 42/42 passed)
serta `flutter analyze` bersih (0 issues) pada saat dokumen ini ditulis.

## 2. Checklist testing manual (fungsional, per fitur)

- [ ] **Family Finance Profile** — isi semua field wajib, validasi angka negatif ditolak, data tersimpan setelah app di-restart.
- [ ] **FVS Dashboard** — skor dan kategori (Aman/Waspada/Rentan/Kritis) berubah konsisten setelah profil diperbarui; breakdown S1-S7 tampil benar.
- [ ] **Emergency Simulation** — jalankan keenam skenario (PHK, medis, cicilan naik, inflasi, pendidikan, tanggungan), pastikan FVS before/after dan rekomendasi mitigasi tampil.
- [ ] **Inflation Calculator** — input primary needs + inflation rate menghasilkan proyeksi pengeluaran dan status dana darurat yang konsisten dengan `InflationImpactCalculator`.
- [ ] **Recommendation Engine** — task harian/30/60/90 hari sesuai kategori FVS; quick action Smart Routing & Savings Vault tampil bila S3 rendah.
- [ ] **Smart Routing** — alokasi pie chart total 100%, kategori berubah sesuai kategori FVS terbaru.
- [ ] **Expense Anomaly Detection** — input pengeluaran kategori "Makanan" naik >50% dari rata-rata historis → status Anomali Tinggi muncul beserta warning message.
- [ ] **Early Warning Notification** — trigger dana darurat <3 bulan, rasio cicilan >35%, anomali pengeluaran, dan penurunan skor FVS masing-masing memunculkan warning di `EarlyWarningPage` dan local notification.
- [ ] **Literacy Module** — buka modul terkait indikator FVS terlemah dari halaman rekomendasi, tandai sudah dibaca, progress tersimpan setelah restart.
- [ ] **Savings Vault** — buat vault baru dengan kategori dari 5 pilihan tertutup, tambah/kurangi saldo, progress percentage dan rekomendasi setoran bulanan terhitung benar.
- [ ] **Community** — buat posting (kategori dari 6 pilihan spec), tambah komentar, tandai komentar helpful, laporkan posting (status berubah ke Flagged).
- [ ] **Reward Points** — poin bertambah benar untuk tiap aktivitas (posting +10, komentar +5, helpful +20, modul literasi +3, vault selesai +25); badge naik sesuai threshold (0/50/100/200).

## 3. Command terminal

```bash
# Jalankan seluruh automated test
flutter test

# Jalankan satu file test spesifik
flutter test test/features/fvs_dashboard/fvs_calculator_test.dart

# Static analysis (harus "No issues found!")
flutter analyze

# Build APK release (siap di-install ke device Android)
flutter build apk --release

# (Opsional) Build APK per-ABI agar ukuran file lebih kecil untuk demo
flutter build apk --release --split-per-abi
```

Output APK release berada di:
`build/app/outputs/flutter-apk/app-release.apk`

## 4. Checklist UI polish

- **Warna** — pastikan semua status risiko (Aman/Waspada/Rentan/Kritis dan Normal/Ringan/Tinggi) memakai palet `AppColors.riskSafe/riskWarning/riskCritical` secara konsisten di semua halaman, bukan warna ad-hoc.
- **Spacing** — padding antar section konsisten (16px horizontal pada halaman, 8-12px antar card) — bandingkan Dashboard, Recommendation, Community, Vault.
- **Card** — semua card pakai `AppCard` (border radius & shadow konsisten), bukan `Container` custom yang berbeda gaya.
- **Chart** — `PieChart`/`LineChart` (fl_chart) di Smart Routing & Dashboard punya legend yang terbaca dan tidak overflow di layar kecil (test di lebar 360px).
- **Empty state** — Savings Vault, Community, Literacy progress, dan riwayat transaksi vault menampilkan pesan + ikon saat data kosong (bukan layar putih kosong).
- **Error state** — setiap `BlocBuilder` yang punya state Error (Fvs, FamilyProfile, Vault, Community) menampilkan pesan kesalahan + tombol "Coba Lagi".
- **Loading state** — setiap halaman yang fetch data async menampilkan `CircularProgressIndicator` sebelum konten tampil, tidak ada flash/flicker konten kosong.

## 5. Checklist build APK

- [ ] `flutter analyze` bersih (0 issues).
- [ ] `flutter test` semua lulus.
- [ ] Versi & build number di `pubspec.yaml` (`version: 1.0.0+1`) sudah sesuai rencana rilis.
- [ ] `flutter build apk --release` sukses tanpa error.
- [ ] APK hasil build (`app-release.apk`) di-install dan dicoba di device/emulator fisik, bukan hanya `flutter run` debug.
- [ ] Icon aplikasi dan nama aplikasi (`AndroidManifest.xml` label) sudah final, bukan default Flutter.

> Catatan environment: pada mesin development saat ini, Android cmdline-tools
> belum terpasang penuh (`flutter doctor` menandai Android toolchain dengan
> peringatan). Jalankan `flutter doctor --android-licenses` dan pasang
> Android SDK cmdline-tools sebelum menjalankan `flutter build apk --release`
> di mesin lain yang akan dipakai untuk build rilis final.

## 6. Checklist demo lomba

- [ ] Device/emulator demo sudah diisi data dummy yang realistis (bukan kosong) untuk semua fitur: profil keluarga, FVS, riwayat pengeluaran, vault, komunitas, reward.
- [ ] Koneksi internet demo stabil (untuk Firebase Auth) atau siapkan akun yang sudah login sebelumnya sebagai cadangan.
- [ ] Baterai device/laptop demo terisi penuh; siapkan charger.
- [ ] Notifikasi local (Early Warning) sudah diberi izin (Android 13+ butuh permission notifikasi).
- [ ] Siapkan 1 skenario "kegagalan terkendali" (contoh: profil belum diisi) untuk menunjukkan empty/error state, bukan hanya jalur sukses.
- [ ] Screenshot/recording cadangan disiapkan seandainya live demo gagal karena jaringan venue.

## 7. Urutan demo aplikasi saat presentasi

1. **Pembuka** — splash screen → onboarding singkat → login (tunjukkan auth keluarga: head of family + anggota).
2. **Family Finance Profile** — isi/lihat profil keuangan keluarga sebagai data dasar.
3. **FVS Dashboard** — tunjukkan skor FVS, kategori, dan breakdown S1-S7 (nilai inti produk).
4. **Emergency Simulation** — jalankan 1 skenario krisis (misalnya PHK) untuk menunjukkan dampak ke FVS secara real-time.
5. **Recommendation Engine** — tunjukkan rekomendasi yang otomatis berubah sesuai kategori FVS, klik salah satu task untuk masuk ke Literacy Module terkait.
6. **Smart Routing** — tunjukkan alokasi otomatis pendapatan sesuai kategori FVS.
7. **Expense Anomaly Detection** — input pengeluaran yang melonjak, tunjukkan deteksi anomali dan estimasi dampak ke FVS.
8. **Early Warning Notification** — tunjukkan notifikasi/peringatan aktif berdasarkan kombinasi sinyal di atas.
9. **Savings Vault** — buat/tambah setoran vault Dana Darurat, tunjukkan progress bar dan rekomendasi setoran bulanan.
10. **Community & Reward Points** — buat posting, beri komentar, tandai helpful, tunjukkan poin & badge bertambah secara live.
11. **Penutup** — ringkas value proposition: FVS sebagai indikator tunggal kesehatan finansial keluarga, didukung simulasi, rekomendasi, dan komunitas yang saling terhubung.
