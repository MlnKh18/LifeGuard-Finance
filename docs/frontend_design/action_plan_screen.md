# Rencana Tampilan: Rencana Aksi Mitigasi

Halaman panduan mitigasi preventif yang membagi aksi perbaikan menjadi 3 periode waktu (30, 60, dan 90 hari) dengan format ceklis interaktif.

---

## 🎨 1. Spesifikasi Visual
*   **Navigasi Periode**: Menggunakan `TabBar` Material 3 dengan garis indikator biru cerah di bagian atas untuk membagi 30, 60, dan 90 hari.
*   **Progress Card**: Menampilkan progress bar di bagian atas setiap tab yang bertambah panjang secara dinamis saat tugas ditandai selesai.
*   **Expandable Tasks**: Menggunakan `ExpansionTile` yang dapat dilipat/dibuka. Ketika dilipat hanya menampilkan judul, kategori, dan prioritas. Ketika dibuka, menampilkan detail cara pengerjaan aksi mitigasi tersebut.
*   **Checklist Status**: Tugas yang telah dicentang akan memiliki coretan garis tengah (*line-through*) dan warnanya memudar (*muted*) untuk menandakan penyelesaian.

---

## 🏗️ 2. Struktur Hierarki Widget (Layout Tree)

```text
Scaffold (AppBar: "Rencana Aksi Mitigasi" + TabBar: [30 Hari], [60 Hari], [90 Hari])
└── TabBarView (3 Children: 30 Days List, 60 Days List, 90 Days List)
    └── Column (For each tab list)
        ├── ProgressCard (Container - Rounded: 16, Background: AppColors.surface)
        │   └── Column
        │       ├── Row (Title: "Progres Tindakan Preventif" + Percentage: "60%")
        │       ├── LinearProgressIndicator (Height: 8, Color: Teal)
        │       └── Text ("3 dari 5 aksi selesai dikerjakan")
        │
        └── Expanded -> ListView.builder (Tugas Ceklis)
            └── Container (Task Tile Container, Border: Safe Green if checked)
                └── ExpansionTile (Checkable Tile)
                    ├── leading: Checkbox (Value: isChecked, Color: Green)
                    ├── title: Text (Judul Tugas, Strike-through if checked)
                    ├── subtitle: Row (Badges)
                    │   ├── CategoryBadge (e.g. "Dana Darurat")
                    │   └── PriorityBadge (e.g. "Tinggi" - Red, "Sedang" - Yellow)
                    │
                    └── children: [Expandable Content]
                        └── Padding (Bottom, Left: 40)
                            ├── Divider
                            └── Text (Detail penjelasan panduan mitigasi taktis)
```

---

## ⚙️ 3. Integrasi State & Data (Riverpod)
*   **State yang digunakan**:
    *   `recommendationsProvider`: Menghasilkan daftar rekomendasi secara dinamis berdasarkan skor FVS terendah (Derived State).
*   **Manajemen Status Ceklis**:
    *   Menggunakan local state set (`Set<String> _checkedTaskTitles`) pada `StatefulWidget` untuk menyimpan daftar tugas yang berhasil dicentang sementara. 
    *   Di masa depan (produksi), status ini dapat dipindahkan ke SQLite agar tersimpan secara permanen di perangkat pengguna.
