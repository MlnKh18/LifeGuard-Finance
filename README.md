# LifeGuard Finance

## 1. Overview
Welcome to the root repository of LifeGuard Finance. This project is a mobile-first personal finance platform designed to provide users with real-time financial health monitoring, proactive budgeting insights, and AI-driven spending anomaly protection.

This repository serves as a monorepo workspace holding the mobile client code, backend gateway, and machine learning engine.

## 2. Workspace Structure
The project is split into three main isolated directories:

```text
lifeguard-finance/
├── frontend/          # Mobile application
├── backend/           # Core API gateway
├── machine-learning/  # AI models and forecasting engine
└── README.md
```

## 3. Detailed Architectural Overview
LifeGuard Finance relies on an interconnected, three-tier architecture designed for high performance, scalability, and security.

### 3.1. The Client (Frontend)
Developed using **Flutter**, the mobile application ensures a seamless cross-platform experience (iOS and Android). 
- **State Management**: Utilizes the **BLoC (Business Logic Component)** pattern to separate presentation from business logic, ensuring predictable state transitions.
- **Local Storage & Caching**: Employs **Hive**, a lightweight and fast NoSQL database, for offline data persistence, caching user profiles, and keeping the app fully functional in low-connectivity environments.
- **Authentication**: Integrated with **Firebase Authentication** for secure login, supporting modern authentication standards and seamless user session management.
- **User Interface**: Designed with custom dynamic themes, micro-animations, and a highly responsive layout to deliver a premium user experience.

### 3.2. The Core (Backend API Gateway)
The backend is built with **Node.js** and **Express.js**, acting as a centralized and secure API gateway.
- **Database & ORM**: Uses **Prisma ORM** coupled with a **PostgreSQL** database to handle complex relational data queries efficiently. Prisma ensures type safety and predictable database schemas.
- **Business Logic Integration**: The backend handles all central business rules, including transaction processing, smart routing algorithms, and Family Finance Profile synchronizations.
- **Security**: Protects sensitive financial data through JWT-based authentication, environment variable encryption, and secure API endpoint routing.

### 3.3. The Intelligence (Data & Machine Learning)
This service acts as the analytical powerhouse of LifeGuard Finance, focused on behavior forecasting and risk mitigation.
- **Anomaly Detection**: Analyzes spending behaviors in real-time to detect fraudulent or unusual spikes in expenditures, immediately relaying alerts to the user.
- **Financial Simulation (FVS & Routing)**: Provides predictive financial forecasting, calculating inflation impacts and simulating emergency scenarios to recommend the best savings vaults.
- **Recommendation Engine**: Generates proactive financial advice and personalized literacy modules based on the user's historical transaction data.

## 4. Demo Account (For Judges' Evaluation)
Below are the demo account credentials that the judging team can use to log in and fully test the application's features without having to register:

- **Email**: `juri@lifeguard.com`
- **Password**: `juri12345`

*(Note: Please ensure these credentials match your testing database before submitting)*