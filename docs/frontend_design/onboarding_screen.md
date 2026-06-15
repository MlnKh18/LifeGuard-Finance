# Rencana Tampilan: Onboarding Wizard Form

Halaman ini mengumpulkan data dasar demografi dan finansial pengguna melalui 3 langkah form (wizard) interaktif untuk menghitung FVS Score pertama kali.

---

## 🎨 1. Spesifikasi Visual
*   **Layout Navigasi**: Header AppBar standar dengan tombol "Kembali" dinamis (hanya muncul pada langkah $\ge$ 2).
*   **Step Indicator**: 3 garis horizontal di bagian atas yang berubah warna menjadi biru terang (`AppColors.primaryLight`) saat langkah tersebut aktif.
*   **Form Style**: Menggunakan `AppStyles.inputDecoration` dengan warna dasar input abu-abu transparan, label mengambang (*floating label*), serta ikon dekoratif di bagian depan (*prefix*).

---

## 🏗️ 2. Struktur Hierarki Widget (Layout Tree)

```text
Scaffold (AppBar: "Profil Keuangan Keluarga")
└── SafeArea
    └── Column
        ├── StepIndicator (Row of 3 expanded horizontal bars)
        │
        ├── Expanded (PageView - Physics: NeverScrollableScrollPhysics)
        │   ├── STEP 1: Profil & Pendapatan (FormKey: _formKey1)
        │   │   └── SingleChildScrollView
        │   │       ├── HeaderText ("Langkah 1: Profil & Pendapatan")
        │   │       ├── DropdownFormField (Kategori Rumah Tangga)
        │   │       ├── DropdownFormField (Jenis Kestabilan Pendapatan)
        │   │       ├── Row (Jumlah Tanggungan: Counter Buttons [-] [0] [+])
        │   │       └── TextFormField (Pendapatan Bersih, Keyboard: Number)
        │   │
        │   ├── STEP 2: Pengeluaran & Tabungan (FormKey: _formKey2)
        │   │   └── SingleChildScrollView
        │   │       ├── HeaderText ("Langkah 2: Pengeluaran & Tabungan")
        │   │       ├── TextFormField (Total Pengeluaran Bulanan, Keyboard: Number)
        │   │       ├── TextFormField (Pengeluaran Pokok/Esensial, Keyboard: Number)
        │   │       └── TextFormField (Tabungan Likuid, Keyboard: Number)
        │   │
        │   ├── STEP 3: Utang & Proteksi (FormKey: _formKey3)
        │   │   └── SingleChildScrollView
        │   │       ├── HeaderText ("Langkah 3: Utang & Proteksi")
        │   │       ├── TextFormField (Total Sisa Utang, Keyboard: Number)
        │   │       ├── TextFormField (Cicilan Bulanan Aktif, Keyboard: Number)
        │   │       ├── SwitchListCard (Proteksi Kesehatan Aktif)
        │   │       └── SwitchListCard (Proteksi Jiwa Aktif)
        │   
        └── Padding (All: 16)
            └── Row (Action Buttons)
                ├── [If Step > 0] OutlinedButton ("Kembali")
                └── ElevatedButton (Text: "Lanjut" atau "Hitung Skor FVS")
```

---

## ⚙️ 3. Integrasi State & Data (Riverpod)
*   **Validasi Form**: Setiap halaman dikunci menggunakan `FormState.validate()`. Nilai input dikonversi dari mata uang rupiah mentah (menghapus format titik desimal) ke format double/int.
*   **Penyimpanan Data**: Tapping "Hitung Skor FVS" pada langkah terakhir memicu:
    ```dart
    final newProfile = FamilyFinanceProfile(...);
    await ref.read(profileStateProvider.notifier).saveProfile(newProfile);
    ```
*   **Pembaruan Otomatis**: Setelah profil berhasil disimpan ke SQLite local-first, `profileStateProvider` akan mendeteksi perubahan state dan secara otomatis mengalihkan rute aplikasi ke `MainNavigation()` dashboard.
