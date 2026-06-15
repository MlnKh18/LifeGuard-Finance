# Rencana Tampilan: Splash Screen

Halaman ini berfungsi sebagai pintu masuk utama aplikasi yang memberikan impresi pertama (branding) dan mengarahkan pengguna baru ke langkah pengisian profil.

---

## 🎨 1. Spesifikasi Visual
*   **Background**: `AppColors.brandGradient` (Linear Gradient diagonal dari Slate Blue ke Teal).
*   **Tema Keterbacaan**: Dark Mode, teks putih cerah.
*   **Animasi (`flutter_animate`)**:
    *   **Logo Shield**: Efek *scale-up* dengan delay `200ms`, durasi `600ms` menggunakan kurva `Curves.backOut`.
    *   **Text Title & Tagline**: Efek *fade-in* (`delay: 400ms`) dan bergeser perlahan ke atas (*slide vertical*).
    *   **Badge Fitur & Button**: Efek *fade-in* (`delay: 800ms - 1000ms`).

---

## 🏗️ 2. Struktur Hierarki Widget (Layout Tree)

```text
Scaffold (Background: brandGradient)
└── SafeArea
    └── Padding (All: 24.0)
        └── Column (MainAxisAlignment: SpaceBetween)
            ├── [Spacer]
            │
            ├── Column (Logo & Tagline - Center)
            │   ├── Container (Circular Border, Glassmorphic white with opacity 0.12)
            │   │   └── Icon (LucideIcons.shieldAlert, Color: White, Size: 72)
            │   ├── SizedBox (Height: 16)
            │   ├── Text ("LifeGuard Finance", FontSize: 34, Bold, Color: White)
            │   ├── SizedBox (Height: 8)
            │   └── Text (Tagline: "Deteksi Risiko Finansial...", Alignment: Center)
            │
            └── Column (Aksi & Badge - Bottom)
                ├── Container (Dark background opacity 0.25, Border: 1px White opacity 0.1)
                │   └── Row (SpaceAround)
                │       ├── FeatureBadge (Icon: Activity, Label: "Detect FVS")
                │       ├── FeatureBadge (Icon: FlaskConical, Label: "Simulate")
                │       └── FeatureBadge (Icon: Compass, Label: "Guide")
                │
                ├── SizedBox (Height: 24)
                ├── ElevatedButton (Text: "Mulai Cek Kondisi Keluarga", Background: White, TextColor: PrimaryBlue)
                │   └── Row (Center)
                │       ├── Text ("Mulai Cek Kondisi Keluarga")
                │       └── Icon (LucideIcons.arrowRight)
                ├── SizedBox (Height: 16)
                └── Text (Disclaimer kecil: "Aplikasi ini bersifat simulatif...", Size: 11, Opacity: 0.6)
```

---

## ⚙️ 3. Integrasi State & Data (Riverpod)
*   **State yang digunakan**: Tidak ada. Halaman ini statis.
*   **Aksi Navigasi**:
    *   Menekan tombol utama akan mengganti route saat ini secara permanen (`Navigator.pushReplacement`) ke halaman `OnboardingScreen()`.
