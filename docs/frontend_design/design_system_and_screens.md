# Panduan Sistem Desain & Katalog Halaman

Dokumen ini merangkum aturan tema antarmuka (UI/UX) serta katalog halaman yang diimplementasikan pada aplikasi **LifeGuard Finance**. Panduan ini berfungsi sebagai acuan utama tim pengembang frontend untuk menjaga konsistensi tampilan.

---

## 🎨 1. Sistem Desain (Design System) & Desain Token

Aplikasi ini menggunakan tema gelap premium (**Premium Dark Slate Theme**) untuk meminimalkan kelelahan mata pengguna ketika memantau data finansial dalam jangka panjang.

### A. Palet Warna (Color Palette)

| Kategori Warna | Nama Variabel | Kode HEX | Peruntukan Visual |
| :--- | :--- | :--- | :--- |
| **Brand Primary** | `primary` | `#1E3A8A` | Warna dasar brand (Slate Blue), tombol utama, dan header |
| **Brand Accent** | `accent` | `#0D9488` | Warna toska untuk status aktif, switch, dan indikator progres |
| **Brand Highlight** | `primaryLight`| `#3B82F6` | Warna biru terang untuk border fokus, step bar, dan indikasi pilih |
| **Latar Belakang** | `background` | `#0F172A` | Background dasar aplikasi (gelap slate) |
| **Permukaan Kartu**| `surface` | `#1E293B` | Warna latar belakang kartu data dan form input |
| **Garis Batas** | `surfaceCard` | `#334155` | Warna border tipis (1px) pembatas kartu |
| **Teks Utama** | `textPrimary` | `#F8FAFC` | Warna putih cerah untuk judul dan teks konten penting |
| **Teks Sekunder** | `textSecondary`| `#94A3B8` | Warna abu-abu kebiruan untuk deskripsi dan label |
| **Teks Muted** | `textMuted` | `#64748B` | Warna abu-abu redup untuk penunjuk waktu/riwayat lama |

### B. Warna Risiko Finansial (FVS Indicator Colors)
Warna dinamis yang digunakan oleh grafik gauge, bar kemajuan, dan penanda status di seluruh halaman:
*   🟢 **Aman / Safe (`#10B981` / Emerald Green)**: Digunakan saat skor FVS $\ge$ 70.
*   🟡 **Waspada / Warning (`#F59E0B` / Amber Yellow)**: Digunakan saat skor FVS berkisar 55 - 69.
*   🟠 **Rentan / Vulnerable (`#F97316` / Orange)**: Digunakan saat skor FVS berkisar 40 - 54.
*   🔴 **Kritis / Critical (`#EF4444` / Crimson Red)**: Digunakan saat skor FVS $<$ 40.

### C. Tipografi (Typography)
*   **Font Judul & UI**: `Outfit` (Kombinasi modern, melengkung halus, dan memberikan kesan bersahabat/aman).
*   **Font Data Numerik**: `Inter` (Presisi tinggi pada digit angka, sangat cocok untuk grafik dan nilai nominal mata uang).

### D. Dekorasi Permukaan (Glassmorphism & Shadows)
*   **Card Decoration**: Menggunakan border `1px` berwarna `surfaceCard` dengan opasitas 30% hingga 50% dan lengkungan sudut `16.0` (`radiusMedium`) untuk menciptakan kedalaman bertumpuk yang modern.

---

## 📱 2. Katalog Halaman (Screen Catalog)

LifeGuard Finance memiliki **6 Halaman Utama** yang terbagi dalam pilar-pilar FVS:

### 1. Splash Screen
*   **Tujuan**: Halaman perkenalan branding aplikasi saat pertama kali dibuka.
*   **Penerapan Tema**: Menggunakan latar belakang gradasi penuh `brandGradient` dengan logo perisai yang membesar lembut (*scale transition*) saat halaman dimuat.

### 2. Onboarding Wizard Form
*   **Tujuan**: Pengisian data profil finansial awal pengguna.
*   **Penerapan Tema**: Form terbagi ke dalam 3 tab PageView. Masukan teks (*text fields*) menggunakan latar transparan dengan placeholder muted grey. Dilengkapi dengan indikator langkah bar di bagian atas.

### 3. Dashboard Utama
*   **Tujuan**: Halaman ringkasan kondisi kesehatan keuangan keluarga.
*   **Penerapan Tema**: Menampilkan grafik setengah lingkaran interaktif `CircularGauge` di bagian tengah yang warnanya berubah mengikuti skor FVS. Di bawahnya terdapat 7 kartu indikator vertikal yang dapat diklik untuk membuka Bottom Sheet detail perhitungan.

### 4. Simulasi Skenario Darurat (Sandbox)
*   **Tujuan**: Tempat menguji ketahanan keuangan terhadap potensi krisis.
*   **Penerapan Tema**: Slider input modern untuk mengatur durasi atau nilai biaya darurat. Hasil kalkulasi ditampilkan dalam kartu perbandingan bersinar (*neon glow border*) yang warnanya mencerminkan skor proyeksi pasca-krisis.

### 5. Rencana Aksi Mitigasi
*   **Tujuan**: Panduan checklist tindakan preventif berskema 30/60/90 hari.
*   **Penerapan Tema**: Layout navigasi 3 tab (*30 Hari*, *60 Hari*, *90 Hari*) dengan progress bar pencapaian di bagian atas. Ceklist tugas yang dicentang akan otomatis memudar warnanya dan dicoret sebagai penanda sukses.

### 6. Pengaturan & Privasi
*   **Tujuan**: Menu kontrol sistem, aktivasi PIN pengunci, disclaimer hukum, dan penghapusan data.
*   **Penerapan Tema**: Pembagian menu ke dalam kotak-kotak kartu dengan judul kategori berhuruf kapital tipis. Tombol "Hapus Seluruh Data" berwarna merah kritis menyala untuk meminimalkan ketidaksengajaan klik.
