# Rencana Tampilan: Pengaturan & Privasi

Halaman kontrol sistem untuk memperbarui profil, mengelola enkripsi/PIN pengunci lokal, penafian hukum, serta opsi penghapusan seluruh data (*data purging*) demi keamanan data privat pengguna.

---

## 🎨 1. Spesifikasi Visual
*   **Kategori List**: Menu dibagi ke dalam beberapa kategori berhuruf kapital tipis (PROFIL, KEAMANAN, PRIVASI, KOMPETISI) untuk memisahkan menu secara visual.
*   **Menu Containers**: Setiap kategori dibungkus dalam Container bersudut melengkung (*rounded card*) dengan batas garis tipis agar kontras dengan warna dasar latar belakang.
*   **Switch Controls**: Fitur keamanan menggunakan tombol geser (*Switch*) aktif berwarna toska.
*   **Tindakan Kritis**: Tombol hapus data berwarna merah terang (`AppColors.critical`) untuk memberi tanda peringatan tingkat bahaya tinggi.

---

## 🏗️ 2. Struktur Hierarki Widget (Layout Tree)

```text
Scaffold (AppBar: "Pengaturan")
└── ListView (Padding: 16)
    ├── CategoryLabel ("PROFIL & KEUANGAN")
    ├── Container (Group Card)
    │   └── ListTile (Edit Profil Finansial, Trailing: ChevronRight)
    │
    ├── CategoryLabel ("KEAMANAN & PREFERENSI")
    ├── Container (Group Card)
    │   ├── SwitchListTile (Aktifkan PIN Pengunci, Value: _pinEnabled)
    │   ├── Divider
    │   └── SwitchListTile (Notifikasi Peringatan, Value: _notificationsEnabled)
    │
    ├── CategoryLabel ("PRIVASI & LEGALITAS")
    ├── Container (Group Card)
    │   ├── ListTile (Disclaimer Hukum, Trailing: InfoIcon)
    │   ├── Divider
    │   └── ListTile (Hapus Seluruh Data Lokal, TextColor: Red, Icon: Trash)
    │
    ├── CategoryLabel ("KOMPETISI & VERSI")
    └── Container (Group Card)
        └── Padding (All: 16)
            └── Text (Detail RAKERNAS IndoCEISS 2026, Versi: 1.0.0)
```

---

## ⚙️ 3. Integrasi State & Data (Riverpod)
*   **Aksi Reset Total (Privacy Purge)**:
    *   Tapping pada "Hapus Seluruh Data Lokal" memicu dialog konfirmasi (`AlertDialog`) terlebih dahulu.
    *   Jika pengguna menekan tombol "Ya, Hapus Data", aplikasi memanggil fungsi global dari Riverpod:
        ```dart
        final resetFn = ref.read(databaseResetProvider);
        await resetFn();
        ```
    *   Fungsi ini menghapus seluruh tabel SQLite, membersihkan status Riverpod, dan secara otomatis mengembalikan antarmuka pengguna ke `SplashScreen()` onboarding karena profil keuangan bernilai `null`.
*   **Simulasi PIN**: Pengontrol lokal `_pinEnabled` digunakan untuk mengontrol simulasi pengaman sidik jari/PIN pada prototype.
