# LifeGuard Finance Backend

Production-ready backend API for LifeGuard Finance — a mobile-first personal finance platform with AI-driven financial health monitoring.

## Tech Stack

- **Runtime**: Node.js 18+
- **Language**: TypeScript
- **Framework**: Express.js 5
- **Database**: Supabase PostgreSQL
- **ORM**: Prisma
- **Auth**: Firebase Authentication (JWT)
- **Validation**: Zod
- **Docs**: Swagger UI / OpenAPI 3.1
- **Deployment**: Vercel

## Architecture

- Modular Monolith
- Clean Architecture (Controller → Service → Repository)
- Adapter Pattern for ML integration
- RBAC with Firebase JWT

## Quick Start

```bash
pnpm install
cp .env.example .env
pnpm prisma:generate
pnpm prisma:migrate
pnpm prisma:seed
pnpm dev
```

API will be available at `http://localhost:3000`
Swagger UI at `http://localhost:3000/api/docs`

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | Supabase pooled connection string |
| `DIRECT_URL` | Yes | Supabase direct connection string |
| `FIREBASE_PROJECT_ID` | Yes | Firebase project ID |
| `FIREBASE_CLIENT_EMAIL` | Yes | Firebase admin service account email |
| `FIREBASE_PRIVATE_KEY` | Yes | Firebase admin private key |
| `ML_SERVICE_URL` | Yes | ML service base URL |
| `CORS_ORIGIN` | No | CORS origin (default: *) |
| `PORT` | No | Server port (default: 3000) |
| `RATE_LIMIT_WINDOW_MS` | No | Rate limit window (default: 900000) |
| `RATE_LIMIT_MAX` | No | Rate limit max requests (default: 100) |

## Project Structure

```
backend/
├── api/                    # Vercel entry point
├── prisma/                 # Schema & migrations
├── src/
│   ├── modules/
│   │   ├── auth/           # Authentication
│   │   ├── users/          # User management
│   │   ├── profiles/       # Family profiles
│   │   ├── incomes/        # Income records
│   │   ├── expenses/       # Expense records
│   │   ├── debts/          # Debt obligations
│   │   ├── dependents/     # Dependents
│   │   ├── protections/    # Insurance/protection
│   │   ├── fvs/            # Financial Vulnerability Score
│   │   ├── simulations/    # What-if simulations
│   │   ├── recommendations/# ML recommendations
│   │   ├── anomalies/      # Expense anomalies
│   │   ├── notifications/  # Notifications
│   │   ├── literacy/       # Financial literacy
│   │   ├── vaults/         # Savings vaults
│   │   ├── community/      # Community posts
│   │   ├── rewards/        # Gamification
│   │   └── ml/             # ML adapter layer
│   ├── shared/
│   │   ├── prisma/         # DB client
│   │   ├── firebase/       # Firebase admin
│   │   ├── middleware/      # Auth, validation, errors
│   │   ├── swagger/        # OpenAPI spec
│   │   ├── types/          # Shared types
│   │   ├── utils/          # Utilities
│   │   └── constants/      # Constants
│   ├── app.ts              # Express app
│   └── server.ts           # Dev server
├── vercel.json
├── package.json
└── tsconfig.json
```

## API Endpoints

All endpoints are prefixed with `/api/v1`.

| Module | Endpoints |
|--------|-----------|
| Auth | `GET /auth/me`, `POST /auth/sync-user` |
| Users | `GET /users/me`, `PATCH /users/me` |
| Profiles | CRUD `/profiles` |
| Incomes | CRUD `/incomes` |
| Expenses | CRUD `/expenses` |
| Debts | CRUD `/debts` |
| Dependents | CRUD `/dependents` |
| Protections | CRUD `/protections` |
| FVS | `POST /fvs/calculate`, `GET /fvs/history`, `GET /fvs/latest`, `GET /fvs/:id` |
| Simulations | `POST /simulations`, `GET /simulations`, `GET /simulations/:id`, `DELETE /simulations/:id` |
| Recommendations | `GET /recommendations`, `GET /recommendations/:id` |
| Anomalies | `POST /anomalies/detect`, `GET /anomalies`, `GET /anomalies/:id` |
| Notifications | `GET /notifications`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all` |
| Literacy | `GET /literacy`, `GET /literacy/:id` |
| Vaults | CRUD `/vaults` |
| Community | CRUD `/community/posts`, CRUD `/community/comments` |
| Rewards | `GET /rewards`, `GET /rewards/history` |

## ML Integration

The backend communicates with an external ML service (Python/FastAPI) via REST:

- `POST /fvs/calculate` → ML calculates Financial Vulnerability Score
- `POST /recommendations/generate` → ML generates recommendations
- `POST /anomalies/detect` → ML detects expense anomalies
- `POST /simulations/run` → ML runs financial simulations

Backend never performs ML calculations directly.

## Deployment (Vercel)

```bash
npm i -g vercel
vercel --prod
```

Set all environment variables in Vercel dashboard.

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm dev` | Start dev server with hot reload |
| `pnpm build` | Build for production |
| `pnpm start` | Start production server |
| `pnpm prisma:generate` | Generate Prisma client |
| `pnpm prisma:migrate` | Run migrations |
| `pnpm prisma:seed` | Seed database |
| `pnpm prisma:studio` | Open Prisma Studio |