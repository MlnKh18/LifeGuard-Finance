# Rencana Tampilan: Simulasi Skenario Darurat

Halaman simulasi (sandbox) yang memungkinkan pengguna melihat dampak langsung dari berbagai skenario krisis (PHK, biaya medis mendadak, kenaikan suku bunga, inflasi) terhadap skor kesehatan finansial mereka secara real-time.

---

## 🎨 1. Spesifikasi Visual
*   **Scenario Selection**: Pilihan skenario disajikan dalam bentuk horizontal chip menu dengan ikon dan label yang bersih.
*   **Interactive Sliders**: Setiap kontrol slider menampilkan parameter dinamis yang mudah dibaca (misalnya: "3 Bulan", "Rp 20 Juta").
*   **Result Card**: Desain dengan batas warna (*border*) yang dinamis sesuai tingkat keparahan dampak (jika skor proyeksi turun drastis menjadi kritis, batas kartu akan bersinar merah menyala).
*   **Diferensiasi Skor**: Menampilkan skor awal berdampingan dengan skor proyeksi pasca-krisis, disertai tanda arah penurunan skor.

---

## 🏗️ 2. Struktur Hierarki Widget (Layout Tree)

```text
Scaffold (AppBar: "Simulasi Skenario Darurat")
└── SingleChildScrollView
    └── Padding (All: 16)
        └── Column (CrossAxisAlignment: Start)
            ├── HeaderText ("Pilih Skenario Krisis")
            ├── Wrap (Scenario Chips)
            │   ├── ChoiceChip (PHK: Kehilangan Pendapatan)
            │   ├── ChoiceChip (Medical: Biaya Medis Darurat)
            │   ├── ChoiceChip (Cicilan: Kenaikan Suku Bunga)
            │   └── ChoiceChip (Inflasi: Kenaikan Harga Pokok)
            │
            ├── SizedBox (Height: 24)
            ├── HeaderText ("Parameter Simulasi")
            ├── Container (Card Style: AppStyles.cardDecoration)
            │   └── Column (Dynamic controls based on selected chip)
            │       ├── [PHK]: Slider (Estimasi Masa Menganggur: 1-12 Bulan)
            │       ├── [Medical]: Slider (Besaran Biaya Medis: Rp 1Jt - Rp 100Jt)
            │       ├── [Cicilan]: Slider (Kenaikan Cicilan per Bulan: Rp 100Rb - Rp 10Jt)
            │       └── [Inflasi]: Slider (Persentase Kenaikan Pengeluaran: 5% - 50%)
            │
            ├── SizedBox (Height: 24)
            ├── ElevatedButton ("Simulasikan Dampak Keuangan", Icon: Play)
            │
            ├── SizedBox (Height: 32)
            ├── [If Simulation Run] Column (Hasil Proyeksi)
            │   ├── HeaderText ("Hasil Proyeksi Dampak")
            │   └── Container (Output Card - Border: Red/Orange)
            │       ├── Row (Score Comparison: Before vs After)
            │       │   ├── Column (Skor Awal: e.g. 75, Green)
            │       │   ├── Icon (LucideIcons.arrowRight)
            │       │   └── Column (Skor Proyeksi: e.g. 38, Red)
            │       ├── Divider
            │       ├── ResultRow (Survival Month: e.g. "2.1 Bulan", Icon: Hourglass)
            │       ├── ResultRow (Defisit Bulanan: e.g. "Rp 4.5 Juta", Icon: TrendingDown)
            │       └── ResultRow (Estimasi Sisa Tabungan, Icon: PiggyBank)
```

---

## ⚙️ 3. Integrasi State & Data (Riverpod)
*   **State Input**: Membaca profil dasar saat ini (`profileStateProvider`) sebagai acuan nominal awal (Pendapatan & Pengeluaran dasar).
*   **Aksi Simulasi**: Menekan tombol simulasikan memicu:
    ```dart
    final result = SimulationEngine.run(
      profile: profile,
      scenarioType: _selectedScenario,
      durationMonths: duration,
      amount: amount,
    );
    // Menyimpan riwayat simulasi ke database lokal
    ref.read(simulationHistoryProvider.notifier).addSimulation(result);
    ```
*   **Keluaran UI**: Variabel lokal `_latestResult` diperbarui, memicu gambar ulang (*rebuild*) visualisasi perbandingan skor.
