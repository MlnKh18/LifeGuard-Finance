# ⚙️ LifeGuard Finance Backend

Production-ready, type-safe Backend API Gateway for the **LifeGuard Finance** platform. This server manages core business logic, database transactions, user profiles, notifications, and delegates financial intelligence requests to the Machine Learning service.

---

## 🛠️ Technology Stack

* **Runtime**: Node.js (v18+)
* **Language**: TypeScript
* **Web Framework**: Express.js 5
* **Database**: PostgreSQL (hosted on Supabase)
* **ORM**: Prisma Client
* **Auth**: Firebase Admin SDK (JWT Validation)
* **Validation**: Zod (Runtime Schema Validation)
* **API Docs**: Swagger UI / OpenAPI 3.1
* **Hosting**: Vercel

---

## 🏛️ Architectural Design

* **Clean Architecture**: Standardized dependency flow: **Controller** (HTTP routing) → **Service** (business logic validation) → **Repository** (database access layer).
* **Modular Monolith**: Organized into domain-specific modules (`auth`, `users`, `profiles`, `incomes`, `expenses`, etc.).
* **Adapter Pattern**: A clean adapter layer abstracts interaction with the FastAPI Machine Learning server.
* **Security Middleware**: Role-Based Access Control (RBAC) and request rate limiting.

---

## 🚀 Dev Setup & Installation

To run the backend gateway locally:

### 1. Prerequisite Installations
Ensure you have **Node.js** and **pnpm** installed:
```bash
npm install -g pnpm
```

### 2. Install Packages
```bash
pnpm install
```

### 3. Configure Environment
Create a copy of the env template and fill in the values:
```bash
cp .env.example .env
```
*(Refer to the [Environment Variables](#-environment-variables) section below).*

### 4. Build database schema and seed data
Generate the database client and execute database seeding:
```bash
# Generate Prisma types
pnpm prisma:generate

# Run DB migrations
pnpm prisma:migrate

# Populate with starter data
pnpm prisma:seed
```

### 5. Launch Dev Server
```bash
pnpm dev
```
* Dev server will start on `http://localhost:3000`.
* Interactive OpenAPI/Swagger Documentation is available at `http://localhost:3000/api/docs`.

---

## 🔑 Environment Variables

The backend relies on the following `.env` configuration:

| Variable | Required | Description |
|:---|:---:|:---|
| `DATABASE_URL` | **Yes** | Transaction-pooled PostgreSQL connection string. |
| `DIRECT_URL` | **Yes** | Direct connection string to PostgreSQL (used for migrations). |
| `FIREBASE_PROJECT_ID` | **Yes** | Firebase project identifier. |
| `FIREBASE_CLIENT_EMAIL`| **Yes** | Client email of the Firebase Admin service account. |
| `FIREBASE_PRIVATE_KEY` | **Yes** | Private key of the Firebase Admin service account (use quotes for formatting). |
| `ML_SERVICE_URL` | **Yes** | The base address of the ML service (e.g. `http://localhost:8000`). |
| `CORS_ORIGIN` | No | CORS allowed origin list (Defaults to `*` if left blank). |
| `PORT` | No | Target port for the server to listen on (Defaults to `3000`). |
| `RATE_LIMIT_WINDOW_MS` | No | Time window size for rate limiter in ms (Default: 15 minutes). |
| `RATE_LIMIT_MAX` | No | Maximum requests per client within the window (Default: 100). |

---

## 📂 Project Structure

```text
Backend/
├── api/                    # Vercel serverless functions entrypoint
├── prisma/                 # Prisma DB Schemas, Migrations, and Seeds
│   ├── migrations/         # PostgreSQL migration history logs
│   ├── schema.prisma       # Relational database models
│   └── seed.ts             # Seeding script for test users & categories
├── src/
│   ├── app.ts              # Express application configuration
│   ├── server.ts           # Local development listener setup
│   ├── modules/            # Domain-specific logic modules
│   │   ├── auth/           # Firebase JWT Validation & synchronization
│   │   ├── users/          # User information & profiles
│   │   ├── profiles/       # Family budget structures
│   │   ├── incomes/        # Income records management
│   │   ├── expenses/       # Expense tracking
│   │   ├── debts/          # Debt logs
│   │   ├── dependents/     # Financial dependents detail
│   │   ├── protections/    # Insurance and safety metrics
│   │   ├── fvs/            # Financial Vulnerability Score triggers
│   │   ├── simulations/    # What-if scenario execution
│   │   ├── recommendations/# ML advisor suggestions
│   │   ├── anomalies/      # Expense anomaly detectors
│   │   ├── notifications/  # User trigger alerts
│   │   ├── literacy/       # Reading materials and educational modules
│   │   ├── vaults/         # Savings goals and vault structures
│   │   ├── community/      # Forum posts & social comments
│   │   ├── rewards/        # User loyalty points and achievements
│   │   └── ml/             # External ML connection adapters
│   └── shared/             # Shared classes, models, and helper middleware
│       ├── prisma/         # Prisma client instances
│       ├── firebase/       # Firebase admin initializer
│       ├── middleware/     # Rate limiter, authorization checks, and error handlers
│       ├── swagger/        # Swagger UI configuration specs
│       ├── types/          # Core TypeScript interface files
│       └── utils/          # General utility functions
└── vercel.json             # Vercel deployment configuration
```

---

## ⚡ API Endpoint Reference

All routes are versioned and prefixed with `/api/v1`. Detailed payloads are documented on the `/api/docs` Swagger page.

| Category | Method | Endpoint | Description |
|:---|:---|:---|:---|
| **Auth** | `GET` | `/auth/me` | Retrieve authorized user info from token |
| | `POST` | `/auth/sync-user` | Sync user state between Firebase & PostgreSQL |
| **Users** | `GET` | `/users/me` | Fetch active user information |
| | `PATCH` | `/users/me` | Edit user registration profile |
| **Profiles** | `GET`/`POST`/`PATCH`/`DELETE` | `/profiles` | CRUD operations on Family profiles |
| **Transactions**| `GET`/`POST`/`PATCH`/`DELETE` | `/incomes`, `/expenses` | Financial record tracking |
| **Liabilities** | `GET`/`POST`/`PATCH`/`DELETE` | `/debts` | Track personal debts & interest rates |
| **Intelligence**| `POST` | `/fvs/calculate` | Compute Financial Vulnerability Score (FVS) |
| | `GET` | `/fvs/history`, `/fvs/latest` | Read historical vulnerability summaries |
| | `POST` | `/simulations` | Simulate inflation and what-if cash-flow shocks |
| | `GET` | `/recommendations` | Get personalized tips & actions generated by AI |
| | `POST` | `/anomalies/detect` | Screen transactions for spending anomalies |
| **Vaults** | `GET`/`POST`/`PATCH`/`DELETE` | `/vaults` | Manage custom target savings |
| **Social** | `GET`/`POST`/`PATCH`/`DELETE` | `/community/posts` | Social discussions and feedback |

---

## 🧠 ML Service Integration

The backend does not compute machine learning metrics natively. Instead, it interacts with the FastAPI Python instance. 

* When a request like `/fvs/calculate` is triggered, the Express gateway converts user profiles into numerical vectors, sends them to `ML_SERVICE_URL/fvs/calculate`, and updates the database with the response results.

---

## 🛠️ CLI Script Index

Useful command commands mapped in `package.json`:

* `pnpm dev`: Start Express development server with automatic file reload (`nodemon`).
* `pnpm build`: Compile TypeScript codebase into production JS in the `dist` directory.
* `pnpm start`: Run the compiled JS production server.
* `pnpm prisma:generate`: Re-build local types for database client.
* `pnpm prisma:migrate`: Sync local schema adjustments to the Supabase database.
* `pnpm prisma:seed`: Wipe and insert baseline mock data.
* `pnpm prisma:studio`: Launch a GUI in your browser to edit database rows directly.