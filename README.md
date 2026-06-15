# LIFEGUARD-FINANCE

## Overview
Welcome to the root repository of LIFEGUARD-FINANCE, a mobile-first personal finance platform designed to provide users with real-time financial health monitoring, proactive budgeting insights, and AI-driven spending anomaly protection.

This repository serves as a monorepo workspace holding the mobile client code, backend gateway, and machine learning engine.

## Folder Structure
```
lifeguard-finance/
├── frontend/          
├── backend/            
├── machine-learning/  
└── README.md
```

## Architectural Overview
LIFEGUARD-FINANCE relies on an interconnected, three-tier micro-architecture optimized for mobile delivery:

- **The Client (Frontend)**: A native or cross-platform mobile application optimized for push-notification delivery, quick user sessions, secure biometric authentication, and offline capability.
- **The Core (Backend)**: A centralized secure API gateway acting as a bridge between the mobile app, database clusters, open-banking APIs, and the machine learning service.
- **The Intelligence (Machine Learning)**: An analytics powerhouse focused on behavior forecasting and risk tracking. This service exposes internal endpoints to flag spending spikes or process predictive text queries before relaying alerts back to the user via the backend.

---

# LifeGuard Finance — Frontend

![LifeGuard Finance Banner](assets/readme_cover.png)

## 🛡️ Early Warning System, Crisis Simulation, and Mitigation Guidance for Family Finances

**LifeGuard Finance** is a local-first mobile application designed to detect, simulate, and mitigate financial vulnerability in household and family environments. It computes the **Financial Vulnerability Score (FVS)** and provides custom actionable 30/60/90-day roadmaps to build long-term economic resilience.

---

## 🎨 Brand Color Palette & Design System

### 1. Brand Core Colors
- **Primary (Slate Indigo - `#1E3A8A`)**: Represents trust, security, and stability.
- **Secondary/Accent (Emerald Teal - `#0D9488`)**: Represents financial balance, growth, and sustainability.
- **Primary Light (Electric Blue - `#3B82F6`)**: Used for active icons, indicator highlights, and focus borders.

### 2. Neutral UI System (Dark Theme)
- **Background (`#0F172A`)**: Dark slate background to reduce eye strain.
- **Surface Card (`#1E293B`)**: Muted slate for card elements and input backdrops.
- **Text Primary (`#F8FAFC`)**: Clean off-white for maximum readability.
- **Text Secondary (`#94A3B8`)**: Cool grey-blue for subtitles and descriptions.

### 3. FVS Risk Indicator Colors
- 🟢 **Aman / Safe (`#10B981`)**: Score ≥ 70
- 🟡 **Waspada / Warning (`#F59E0B`)**: Score 55–69
- 🟠 **Rentan / Vulnerable (`#F97316`)**: Score 40–54
- 🔴 **Kritis / Critical (`#EF4444`)**: Score < 40

---

## 🚀 Key Features

- **Detect (FVS Assessment)**: Multi-step questionnaire computing aggregate FVS across 7 indicators.
- **Simulate (Crisis Sandbox)**: Interactive sliders projecting impact of PHK, Medical Shocks, Inflation, and more.
- **Guide (Action Plan)**: Auto-generated 30/60/90-day task checklist prioritizing emergency buffers and debt management.
- **Privacy by Design (Local-First)**: Fully offline SQLite persistence. Users can purge all records from settings.

---

## 🏗️ Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod
- **Database**: SQLite (`sqflite`)
- **UI/UX**: `flutter_animate`, `lucide_icons`, Material 3 Dark Theme

---

## ⚙️ Getting Started

```bash
git clone <repository_url>
cd life_guard_finance
flutter pub get
flutter run
```
