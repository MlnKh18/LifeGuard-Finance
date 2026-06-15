# Panduan Prompt Desain untuk Stitch (Stitch Design Prompts)

Dokumen ini berisi kumpulan prompt terstruktur dan profesional yang siap disalin dan dimasukkan ke dalam **Stitch** guna menghasilkan desain antarmuka, aset visual, dan komponen antarmuka yang presisi untuk **LifeGuard Finance**.

---

## 🎨 1. Prompt untuk Global Theme & UI Tokens (Stitch Theme)

Gunakan prompt ini di awal proyek Stitch Anda untuk mengunci token warna, radius sudut, bayangan, dan nuansa visual:

```text
Initialize a design system for a premium mobile finance app named 'LifeGuard Finance'. 
The overall style must be 'Premium Glassmorphic Dark Slate'.

Design Tokens Configuration:
- Core Background: Dark Slate Grey (#0F172A).
- Cards & Surfaces: Muted Slate (#1E293B) with a thin border of #334155 (opacity 40%).
- Typography: Use 'Outfit' for all UI headings/labels, and 'Inter' or 'JetBrains Mono' for numbers. Text colors must be White (#F8FAFC) for headers and Cool Grey-Blue (#94A3B8) for secondary text.
- Accent Color: Emerald Teal (#0D9488) for progress bars, active sliders, and primary buttons.
- Secondary Highlight: Electric Blue (#3B82F6) for focus indicators and navigation tabs.

FVS Level Indicators:
- Safe Level: Emerald Green (#10B981)
- Warning Level: Amber Yellow (#F59E0B)
- Vulnerable Level: Orange (#F97316)
- Critical Level: Crimson Red (#EF4444)

Design Guidelines:
- Apply a border radius of 16px to all cards and dialogs.
- Use subtle box shadows for depth instead of heavy borders.
- Keep the design clean, flat, and spacious.
```

---

## 📊 2. Prompt Komponen: Dashboard Circular Gauge

Gunakan prompt ini untuk membuat widget visual utama pada dashboard:

```text
Design a custom circular gauge component for a mobile screen:
- It should show a semi-circular progress arc (gauge pointer).
- Inside the center of the arc, display a large numerical score (e.g., "64") in a bold Inter font, with a verbal level indicator below it (e.g., "Waspada / Warning" in Amber).
- The arc's color must dynamically match the FVS score status: Green for safe, Amber for warning, Orange for vulnerable, and Red for critical.
- Below the gauge, add a small info link with a Lucide info icon that reads 'Lihat parameter penilaian'.
- Use glassmorphism overlays behind the gauge with a subtle 12% opacity white card container.
```

---

## 🎚️ 3. Prompt Komponen: Crisis Simulation Controls & Results

Gunakan prompt ini untuk menghasilkan antarmuka sandbox interaktif:

```text
Design a sandbox simulation interface for financial crisis analysis on a mobile screen:
1. Scenario Selector:
   - A horizontal row of selectable chips with icons (PHK/Job Loss, Medical Emergency, Interest Rate Hike, Inflation Shock).
2. Parameter Controller:
   - A container card containing a smooth slider. The slider handle must be active electric blue. Above the slider, show the label (e.g., 'Estimasi Menganggur: 4 Bulan' or 'Biaya Medis: Rp 25,000,000').
3. Projections Card:
   - A dynamic result card that shows the output comparison. On the left, display 'Skor FVS Awal' (e.g. 75, Green), an arrow indicator pointing right, and on the right display 'Skor Proyeksi' (e.g. 38, Red).
   - Below the score, list three stat rows with icons:
     - 'Bulan Bertahan (Runway)': 2.4 Bulan (with a warning icon)
     - 'Defisit Bulanan': -Rp 3,500,000 (with a downward trend icon)
     - 'Sisa Dana Darurat': Rp 12,000,000.
```

---

## 📋 4. Prompt Komponen: 30/60/90-Day Mitigation Checklist

Gunakan prompt ini untuk membuat tampilan rencana aksi mitigasi:

```text
Design a checkable roadmap screen with a top TabBar divided into: '30 Hari', '60 Hari', and '90 Hari'.
- At the top of each tab, include a compact progress card showing a linear progress indicator (8px height) and a progress text (e.g., '3 dari 5 tindakan selesai (60%)').
- Below the progress bar, display a list of expandable task tiles:
  - Each tile has a leading checkbox, a task title, a category badge (e.g., 'Dana Darurat' in Teal), and a priority badge (e.g., 'Tinggi' in Red).
  - Tapping a tile expands it to reveal a clean card with detailed mitigation instructions.
  - Checked tasks must have their text styled with a line-through, and opacity reduced to 60%.
```

---

## 🔒 5. Prompt Komponen: Settings & Local Privacy

Gunakan prompt ini untuk membuat bagian preferensi keamanan:

```text
Design a settings preference screen for a local-first mobile privacy app:
- Group the options into logical card blocks:
  - Block 1: 'PROFIL KEUANGAN' with a ListTile to edit the family profile.
  - Block 2: 'KEAMANAN' with SwitchListTiles for 'Aktifkan PIN Pengunci' and 'Notifikasi Peringatan'.
  - Block 3: 'PRIVASI & HUKUM' with ListTiles for 'Disclaimer Hukum' and 'Hapus Seluruh Data'.
- The 'Hapus Seluruh Data' option must stand out with bold red text (#EF4444) and a trash can icon.
- Include a compact developer credit section at the bottom mentioning 'LifeGuard Finance Mobile - IndoCEISS Rakernas 2026'.
```
