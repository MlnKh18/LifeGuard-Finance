# Technical Stack and Project Structure: LifeGuard Finance

This document details the selected package stack, custom configuration, and directory structure for the Flutter implementation of **LifeGuard Finance**.

---

## 1. Selected Library Stack (pubspec.yaml)

To build a premium, fast, local-first mobile application, we will use the following libraries:

| Category | Package | Version | Purpose |
|---|---|---|---|
| **State Management** | `flutter_riverpod` | `^2.5.1` | Robust, testable, and reactive state management. |
| **Local Database** | `sqflite` | `^2.3.0` | Relational SQLite database to store FVS history and simulations. |
| | `path` | `^1.9.0` | Helper for database path locating. |
| | `shared_preferences`| `^2.2.3` | Simple key-value storage for PIN, onboarding, and app settings. |
| **UI & Visuals** | `fl_chart` | `^0.66.0` | Dynamic charts to render historical FVS and indicator breakdowns. |
| | `flutter_animate` | `^4.5.0` | High-fidelity micro-animations for cards, scores, and buttons. |
| | `google_fonts` | `^6.1.0` | Typography (Inter/Outfit) for a clean modern appearance. |
| | `lucide_icons` | `^0.320.0` | Beautiful, sleek, modern iconography. |
| **Utilities** | `intl` | `^0.19.0` | Number and currency formatting (Rupiah IDR) and date formatting. |

---

## 2. Directory Structure (Feature-First / Layered Hybrid)

We will organize the code so that logical concerns (data, engine, presentation) are separated. This reduces merge conflicts in a hackathon and makes unit testing the scoring engine straightforward.

```text
lib/
├── main.dart                       # Entry point (initializes DB, loads settings)
├── app.dart                        # MaterialApp configuration, routes, and themes
│
├── constants/
│   ├── app_colors.dart             # Sleek dark mode colors, brand gradient, alert categories
│   ├── app_theme.dart              # Custom Light/Dark ThemeData using GoogleFonts
│   └── app_styles.dart             # Reusable paddings, radii, cards, glassmorphic styling
│
├── data/
│   ├── database/
│   │   └── database_helper.dart    # SQLite helper (table creation, migrations)
│   ├── models/
│   │   ├── finance_profile.dart    # Model for user's inputted financials
│   │   ├── fvs_score.dart          # Computed score results model
│   │   ├── simulation.dart         # Crisis simulation logs model
│   │   └── recommendation.dart     # Recommendation & action plan check item model
│   └── repositories/
│       ├── finance_repository.dart # Local repository for CRUD operations on profiles
│       └── score_repository.dart   # Local repository for score history and simulations
│
├── logic/
│   ├── scoring/
│   │   └── fvs_scoring_engine.dart # Core math for calculating FVS & individual indicators
│   ├── simulation/
│   │   └── simulation_engine.dart  # Logic for survival months and projected impact
│   └── recommendation/
│       └── recommendation_rules.dart # Mapping weak indicators to 30/60/90-day action plans
│
├── providers/
│   └── app_providers.dart          # Riverpod state providers (profile, scoring state, simulation)
│
└── presentation/
    ├── screens/
    │   ├── onboarding/
    │   │   ├── splash_screen.dart  # Branding intro
    │   │   └── onboarding_screen.dart # Stepper value proposition & educational disclaimer
    │   ├── main_navigation.dart    # Nav wrapper containing BottomNavigationBar
    │   ├── dashboard/
    │   │   ├── dashboard_screen.dart  # FVS Circular gauge and quick insights
    │   │   └── breakdown_screen.dart  # Detailed views of FVS components
    │   ├── simulation/
    │   │   └── simulation_screen.dart # Interactive sliders/inputs to run crisis scenarios
    │   ├── action_plan/
    │   │   └── action_plan_screen.dart # 30/60/90 action lists and checkable items
    │   └── settings/
    │       └── settings_screen.dart   # Data reset, PIN code config, and developer credits
    │
    └── widgets/
        ├── circular_gauge.dart      # Animated FVS score indicator
        ├── indicator_card.dart      # Component to show individual category progress & state
        └── custom_button.dart       # Custom animated/glassmorphic action button
```

---

## 3. Development Workflow (Step-by-Step Commits)

We will build the application iteratively using Conventional Commits:

1. **`chore(deps): 🔧 setup pubspec.yaml and folder structure`**
   - Add all packages to `pubspec.yaml`.
   - Create empty directories and skeleton classes.
2. **`feat(theme): 🎨 implement branding and typography system`**
   - Setup Google Fonts, global colors, and MaterialApp dark theme.
3. **`feat(logic): 🧮 implement FVS scoring engine`**
   - Write unit-testable Dart classes for computing scores based on inputs.
4. **`feat(profile): 📝 create family finance profile wizard`**
   - Implement the multi-step form to collect income, debt, savings, etc.
5. **`feat(dashboard): 📊 build FVS circular gauge and dashboard`**
   - Implement the visual center of the application using progress indicators.
6. **`feat(simulation): 🧪 develop crisis simulation logic and UI`**
   - Code the simulation panel with interactive sliders (PHK, medical shock).
7. **`feat(mitigation): 📋 implement action plans and recommendations`**
   - Implement 30/60/90 action checklist.
8. **`feat(db): 💾 persist user profile and scores locally`**
   - Connect SQFlite and Shared Preferences.
9. **`feat(security): 🔒 add local PIN lock and data deletion`**
   - Ensure privacy by design.
