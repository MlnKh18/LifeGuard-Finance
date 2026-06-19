# 📱 LifeGuard Finance — Flutter Client

The official cross-platform mobile client application for the **LifeGuard Finance** platform. Built using Flutter, this app features real-time financial dashboards, interactive what-if simulations, AI-driven recommendations, and localized data persistence.

---

## 🛠️ Mobile Tech Stack

* **Framework**: Flutter SDK ^3.11.1
* **State Management**: BLoC (`flutter_bloc`) & Hydrated BLoC (`hydrated_bloc`) for persistent state caches.
* **Local Database**: Hive CE (`hive_ce_flutter`) for rapid, schema-less offline storage.
* **Service Locator (DI)**: GetIt (`get_it`) for dependency injection.
* **Navigation Router**: GoRouter (`go_router`) for declarative routing.
* **Networking**: Dio (`dio`) equipped with request/response interceptors.
* **Data Visualizations**: FL Chart (`fl_chart`) for interactive charts and score visualizations.
* **Notifications**: Flutter Local Notifications (`flutter_local_notifications`).

---

## 🏛️ Codebase Architecture

The app is built using a **Feature-First Clean Architecture** format, separating code into modular `features` and unified `core` utilities within the `lib/` directory:

```text
lib/
├── core/                  # Core modules shared across all features
│   ├── constants/         # Asset pathways, colors, spacing, and API keys
│   ├── data/              # Base network client & local Hive box management
│   ├── di/                # Dependency injection registrations (GetIt)
│   ├── errors/            # App failures and exceptions
│   ├── network/           # Dio setup, interceptors, and error handlers
│   ├── router/            # GoRouter configurations and app route maps
│   ├── theme/             # App typography (Outfit/Inter) and Dark/Light modes
│   ├── utils/             # Formatters, extension functions, and helpers
│   └── widgets/           # Global reusable UI (custom buttons, loading, input fields)
├── features/              # Feature-driven business logic and screens
│   ├── auth/              # Firebase User login, signup, and token sync
│   ├── onboarding/        # Walkthrough slides for new users
│   ├── splash/            # Startup splash view
│   ├── daily_finance/     # Account balances, income/expense CRUD, and histories
│   ├── fvs_dashboard/     # Financial Vulnerability Score gauge and breakdowns
│   ├── savings_vault/     # Target savings, piggy vaults, and fund transfers
│   ├── emergency_simulation/ # What-if scenario tests and cash-flow shock runs
│   ├── inflation_calculator/ # Compounding inflation and purchasing power calculator
│   ├── smart_routing/     # AI savings allocation recommendations
│   ├── early_warning/     # Custom threshold limits and budget alert notifications
│   ├── anomaly_detection/ # Fraud/irregular transaction spike detection views
│   ├── recommendation/    # Financial advice lists and AI-generated modules
│   ├── rewards/           # Points logs, level systems, and badge achievements
│   ├── family_profile/    # Shared family budgets and profile syncs
│   ├── literacy/          # Curated learning articles and quizzes
│   ├── community/         # Forums, discussions, and member comments
│   └── settings/          # Profile management, theme switchers, and preferences
├── firebase_options.dart  # Firebase generated project configurations
└── main.dart              # App initialization and runner entry point
```

---

## 🚀 Setup & Installation Instructions

Follow these steps to run the application on a local emulator or connected physical device:

### 1. Prerequisites
Ensure you have the Flutter SDK configured:
* Run `flutter doctor` to verify that your environment (Android SDK / Xcode) is correctly configured.

### 2. Fetch Packages
Navigate to this directory (`Frontend/lifeguard_finance`) and execute:
```bash
flutter pub get
```

### 3. Run Code Generation
The app uses code generators for Hive adapters. You **must** compile these files before launching the app:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Setup Firebase
The project relies on Firebase Core and Firebase Auth. Make sure your native configurations are ready:
* Android: Ensure `android/app/google-services.json` is present.
* iOS: Ensure `ios/Runner/GoogleService-Info.plist` is configured.
* Alternatively, update `lib/firebase_options.dart` using the FlutterFire CLI command.

### 5. Launch the Application
Start the application on your active device:
```bash
flutter run
```
*To run in Release mode for optimization testing:*
```bash
flutter run --release
```

---

## 🧪 Unit & State Testing

We utilize the `bloc_test` and `mocktail` libraries to verify state transitions and dependencies. To run all automated unit tests:

```bash
flutter test
```

---

## 📦 Compiling Production Builds

To compile release artifacts for distribution:

### Android APK
```bash
flutter build apk --release
```
*The output APK will be saved at `build/app/outputs/flutter-apk/app-release.apk`.*

### Android App Bundle (AAB for Google Play)
```bash
flutter build appbundle --release
```

### iOS App (macOS & Xcode required)
```bash
flutter build ipa --release
```
