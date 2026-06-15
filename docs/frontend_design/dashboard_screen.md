# Rencana Tampilan: Dashboard Utama

Halaman utama aplikasi yang menampilkan ringkasan skor FVS keluarga, statistik kunci keuangan, dan 7 sub-indikator kerentanan secara detail.

---

## 🎨 1. Spesifikasi Visual
*   **Header Card**: Kartu bergradasi dengan batas tipis (*border: 1px*) menampilkan nama kategori rumah tangga dan rangkuman pendapatan.
*   **Circular Gauge**: CustomPainter berbentuk setengah lingkaran (arc) berwarna sesuai kategori FVS (Hijau, Kuning, Jingga, Merah). Menggunakan `AnimationController` untuk pergerakan jarum/bar dari 0 ke nilai skor saat dimuat.
*   **Grid Stats**: 3 kolom berisi angka penting (Savings Rate, Debt-to-Income, Emergency Buffer) dengan warna penanda visual (aman vs bahaya).
*   **Indicator Cards**: Daftar vertikal berisi kartu ringkasan untuk 7 pilar FVS. Setiap kartu memiliki bilah kemajuan (*linear progress bar*) mini berwarna status.

---

## 🏗️ 2. Struktur Hierarki Widget (Layout Tree)

```text
Scaffold (AppBar: "LifeGuard Dashboard" + Action: BellIcon)
└── SingleChildScrollView
    └── Padding (Horizontal: 16, Vertical: 8)
        └── Column (CrossAxisAlignment: Start)
            ├── GreetingCard (Linear Gradient: PrimaryBlue to Teal, Rounded: 16)
            │   └── Row
            │       ├── Icon (LucideIcons.users, Color: ElectricBlue)
            │       └── Column (Title: "Keluarga Tangguh", Sub: Pendapatan Bulanan)
            │
            ├── SizedBox (Height: 16)
            ├── Center -> CircularGauge (Custom Painted Arc, Score Number & Category)
            ├── SizedBox (Height: 16)
            │
            ├── Row (3 Stat Cards - Equal Width)
            │   ├── StatWidget (Savings Rate, Value: "15%", Color: Yellow)
            │   ├── StatWidget (Debt-to-Income, Value: "25%", Color: Green)
            │   └── StatWidget (Emergency buffer, Value: "2.4 Bln", Color: Orange)
            │
            ├── SizedBox (Height: 24)
            ├── HeaderText ("Breakdown Indikator Kerentanan")
            ├── SizedBox (Height: 8)
            │
            ├── IndicatorCard (1. Kestabilan Pendapatan, Progress: 1.0, Color: Green)
            ├── IndicatorCard (2. Rasio Pengeluaran, Progress: 0.8, Color: Green)
            ├── IndicatorCard (3. Kesiapan Dana Darurat, Progress: 0.4, Color: Orange)
            ├── IndicatorCard (4. Rasio Beban Utang, Progress: 0.5, Color: Yellow)
            ├── IndicatorCard (5. Tanggungan Keluarga, Progress: 0.8, Color: Green)
            ├── IndicatorCard (6. Kesiapan Proteksi, Progress: 0.8, Color: Green)
            └── IndicatorCard (7. Daya Serap Guncangan, Progress: 0.3, Color: Red)
```

---

## ⚙️ 3. Integrasi State & Data (Riverpod)
*   **State yang digunakan**:
    *   `profileStateProvider`: Mengambil total pendapatan, pengeluaran, tabungan, dan cicilan untuk memformat teks rupiah dan menghitung persentase ringkasan (Savings Rate, DTI).
    *   `fvsStateProvider`: Mengambil nilai total skor, kategori verbal, dan skor breakdown masing-masing dari 7 indikator.
*   **Interaksi & Event**:
    *   Tapping pada salah satu `IndicatorCard` memicu `showModalBottomSheet()` berisi detail aturan perhitungan (rule-based formula) serta rekomendasi edukatif singkat sesuai indikator yang dipilih.
