# 📱 LifeGuard Finance Frontend Workspace

This directory is the root workspace for the **LifeGuard Finance** client-side application. It houses the user interface components, client-side routing, state management, offline database integrations, and the core mobile application code.

---

## 📂 Folder Structure

```text
Frontend/
├── lifeguard_finance/     # The primary Flutter mobile application project
│   ├── android/           # Native Android configurations & project metadata
│   ├── assets/            # Fonts, logos, local illustrations, and icons
│   ├── ios/               # Native iOS project setup & configuration
│   ├── lib/               # Dart application codebase (features and core logic)
│   ├── test/              # Unit, Widget, and BLoC verification tests
│   └── pubspec.yaml       # Project packages and assets manifest
└── README.md              # This workspace navigation guide
```

---

## ⚡ Mobile Application Overview

The mobile client is built on **Flutter**, ensuring a highly performant, single-codebase app running natively on both Android and iOS devices.

* **Core Stack**: Flutter SDK ^3.11.1
* **Device Targets**:
  * **Android**: API Level 21+ (Android 5.0+)
  * **iOS**: Target Version 13.0+
* **Prerequisites to Build**:
  * **Flutter SDK**
  * **Android SDK** (for Android builds)
  * **Xcode** & **Cocoapods** (for iOS builds, macOS required)

---

## 🚀 Getting Started

The actual mobile app implementation, source code, and configuration options reside in the `lifeguard_finance/` sub-package.

For detailed instructions on dependencies, code generation (Hive database classes, etc.), Firebase setup, and testing scripts, please refer directly to the application manual:

👉 **[Go to Flutter App Setup & Architecture Guide](file:///C:/Users/maula/Documents/BANTAI%20LOMBA%20NASIONAL/Competition%20RAKERNAS%20IndoCEISS%202026/LifeGuard-Finance/Frontend/lifeguard_finance/README.md)**