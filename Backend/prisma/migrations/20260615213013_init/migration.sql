-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN', 'MODERATOR');

-- CreateEnum
CREATE TYPE "IncomeFrequency" AS ENUM ('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'SEMI_ANNUALLY', 'ANNUALLY', 'ONE_TIME');

-- CreateEnum
CREATE TYPE "ExpenseCategory" AS ENUM ('FOOD', 'TRANSPORTATION', 'HOUSING', 'UTILITIES', 'HEALTHCARE', 'EDUCATION', 'ENTERTAINMENT', 'SHOPPING', 'INSURANCE', 'SAVINGS', 'DEBT_PAYMENT', 'CHARITY', 'PERSONAL_CARE', 'TRAVEL', 'SUBSCRIPTIONS', 'OTHER');

-- CreateEnum
CREATE TYPE "DebtStatus" AS ENUM ('ACTIVE', 'PAID_OFF', 'DEFAULTED', 'RESTRUCTURED');

-- CreateEnum
CREATE TYPE "ProtectionType" AS ENUM ('LIFE_INSURANCE', 'HEALTH_INSURANCE', 'VEHICLE_INSURANCE', 'PROPERTY_INSURANCE', 'TRAVEL_INSURANCE', 'EDUCATION_INSURANCE', 'EMERGENCY_FUND', 'OTHER');

-- CreateEnum
CREATE TYPE "FvsCategory" AS ENUM ('VERY_VULNERABLE', 'VULNERABLE', 'MODERATE', 'STABLE', 'VERY_STABLE');

-- CreateEnum
CREATE TYPE "SimulationType" AS ENUM ('DEBT_PAYOFF', 'SAVINGS_GOAL', 'EXPENSE_REDUCTION', 'INCOME_INCREASE', 'INSURANCE_COVERAGE', 'EMERGENCY_FUND', 'RETIREMENT', 'CUSTOM');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('FVS_UPDATED', 'ANOMALY_DETECTED', 'RECOMMENDATION', 'VAULT_MILESTONE', 'REWARD_EARNED', 'SYSTEM', 'COMMUNITY');

-- CreateEnum
CREATE TYPE "AnomalySeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "LiteracyDifficulty" AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED');

-- CreateEnum
CREATE TYPE "LiteracyCategory" AS ENUM ('BUDGETING', 'SAVING', 'INVESTING', 'DEBT_MANAGEMENT', 'INSURANCE', 'TAX', 'RETIREMENT', 'GENERAL');

-- CreateEnum
CREATE TYPE "MlJobStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "MlJobType" AS ENUM ('FVS_CALCULATION', 'RECOMMENDATION', 'ANOMALY_DETECTION', 'SIMULATION');

-- CreateEnum
CREATE TYPE "RewardAction" AS ENUM ('PROFILE_COMPLETED', 'FVS_CALCULATED', 'VAULT_CREATED', 'VAULT_MILESTONE', 'LITERACY_COMPLETED', 'COMMUNITY_POST', 'COMMUNITY_COMMENT', 'STREAK_LOGIN', 'FIRST_INCOME', 'FIRST_EXPENSE', 'FIRST_DEBT', 'FIRST_PROTECTION');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "firebase_uid" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "display_name" TEXT,
    "avatar_url" TEXT,
    "phone_number" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "last_login_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "family_profiles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT NOT NULL,
    "date_of_birth" TIMESTAMP(3),
    "notes" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "family_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "incomes" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "source" TEXT NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'IDR',
    "frequency" "IncomeFrequency" NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "start_date" TIMESTAMP(3),
    "end_date" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "incomes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "category" "ExpenseCategory" NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'IDR',
    "description" TEXT,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_recurring" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "debts" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "creditor" TEXT NOT NULL,
    "principal" DECIMAL(15,2) NOT NULL,
    "remaining_balance" DECIMAL(15,2) NOT NULL,
    "interest_rate" DECIMAL(5,2) NOT NULL,
    "monthly_payment" DECIMAL(15,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'IDR',
    "status" "DebtStatus" NOT NULL DEFAULT 'ACTIVE',
    "start_date" TIMESTAMP(3),
    "due_date" TIMESTAMP(3),
    "description" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "debts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dependents" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT NOT NULL,
    "date_of_birth" TIMESTAMP(3),
    "needs_education" BOOLEAN NOT NULL DEFAULT false,
    "monthly_cost" DECIMAL(15,2),
    "notes" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "dependents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "protections" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" "ProtectionType" NOT NULL,
    "provider" TEXT NOT NULL,
    "policy_number" TEXT,
    "coverage_amount" DECIMAL(15,2) NOT NULL,
    "premium" DECIMAL(15,2) NOT NULL,
    "premium_frequency" "IncomeFrequency" NOT NULL DEFAULT 'MONTHLY',
    "currency" TEXT NOT NULL DEFAULT 'IDR',
    "start_date" TIMESTAMP(3),
    "expiry_date" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "notes" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "protections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fvs_results" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "score" DECIMAL(5,2) NOT NULL,
    "category" "FvsCategory" NOT NULL,
    "model_version" TEXT NOT NULL,
    "raw_response" JSONB,
    "generated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fvs_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fvs_indicator_results" (
    "id" UUID NOT NULL,
    "fvs_result_id" UUID NOT NULL,
    "indicator_name" TEXT NOT NULL,
    "value" DECIMAL(5,2) NOT NULL,
    "weight" DECIMAL(5,2) NOT NULL,
    "status" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fvs_indicator_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "simulation_results" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" "SimulationType" NOT NULL,
    "title" TEXT,
    "parameters" JSONB NOT NULL,
    "result" JSONB NOT NULL,
    "model_version" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "simulation_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recommendation_results" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "category" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 0,
    "action_url" TEXT,
    "is_dismissed" BOOLEAN NOT NULL DEFAULT false,
    "dismissed_at" TIMESTAMP(3),
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "recommendation_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_anomalies" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "expense_id" UUID,
    "type" TEXT NOT NULL,
    "severity" "AnomalySeverity" NOT NULL,
    "description" TEXT NOT NULL,
    "amount" DECIMAL(15,2),
    "expected_range" JSONB,
    "is_resolved" BOOLEAN NOT NULL DEFAULT false,
    "resolved_at" TIMESTAMP(3),
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "expense_anomalies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" "NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "data" JSONB,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "read_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "literacy_modules" (
    "id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "category" "LiteracyCategory" NOT NULL,
    "difficulty" "LiteracyDifficulty" NOT NULL,
    "cover_image" TEXT,
    "duration" INTEGER,
    "order" INTEGER NOT NULL DEFAULT 0,
    "is_published" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "literacy_modules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "savings_vaults" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "target_amount" DECIMAL(15,2) NOT NULL,
    "current_amount" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL DEFAULT 'IDR',
    "deadline" TIMESTAMP(3),
    "icon_url" TEXT,
    "color" TEXT,
    "is_completed" BOOLEAN NOT NULL DEFAULT false,
    "completed_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "savings_vaults_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "community_posts" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "category" TEXT,
    "is_pinned" BOOLEAN NOT NULL DEFAULT false,
    "likes_count" INTEGER NOT NULL DEFAULT 0,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "community_posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "community_comments" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "post_id" UUID NOT NULL,
    "content" TEXT NOT NULL,
    "likes_count" INTEGER NOT NULL DEFAULT 0,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "community_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reward_points" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "action" "RewardAction" NOT NULL,
    "points" INTEGER NOT NULL,
    "description" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reward_points_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ml_jobs" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "job_type" "MlJobType" NOT NULL,
    "status" "MlJobStatus" NOT NULL DEFAULT 'PENDING',
    "request_payload" JSONB,
    "response_payload" JSONB,
    "error_message" TEXT,
    "started_at" TIMESTAMP(3),
    "completed_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ml_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entity_id" UUID,
    "metadata" JSONB,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_firebase_uid_key" ON "users"("firebase_uid");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_firebase_uid_idx" ON "users"("firebase_uid");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_is_active_idx" ON "users"("is_active");

-- CreateIndex
CREATE INDEX "user_roles_user_id_idx" ON "user_roles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_roles_user_id_role_key" ON "user_roles"("user_id", "role");

-- CreateIndex
CREATE INDEX "family_profiles_user_id_idx" ON "family_profiles"("user_id");

-- CreateIndex
CREATE INDEX "family_profiles_user_id_deleted_at_idx" ON "family_profiles"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "incomes_user_id_idx" ON "incomes"("user_id");

-- CreateIndex
CREATE INDEX "incomes_user_id_deleted_at_idx" ON "incomes"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "incomes_user_id_frequency_idx" ON "incomes"("user_id", "frequency");

-- CreateIndex
CREATE INDEX "expenses_user_id_idx" ON "expenses"("user_id");

-- CreateIndex
CREATE INDEX "expenses_user_id_deleted_at_idx" ON "expenses"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "expenses_user_id_category_idx" ON "expenses"("user_id", "category");

-- CreateIndex
CREATE INDEX "expenses_user_id_date_idx" ON "expenses"("user_id", "date");

-- CreateIndex
CREATE INDEX "debts_user_id_idx" ON "debts"("user_id");

-- CreateIndex
CREATE INDEX "debts_user_id_deleted_at_idx" ON "debts"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "debts_user_id_status_idx" ON "debts"("user_id", "status");

-- CreateIndex
CREATE INDEX "dependents_user_id_idx" ON "dependents"("user_id");

-- CreateIndex
CREATE INDEX "dependents_user_id_deleted_at_idx" ON "dependents"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "protections_user_id_idx" ON "protections"("user_id");

-- CreateIndex
CREATE INDEX "protections_user_id_deleted_at_idx" ON "protections"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "protections_user_id_type_idx" ON "protections"("user_id", "type");

-- CreateIndex
CREATE INDEX "fvs_results_user_id_idx" ON "fvs_results"("user_id");

-- CreateIndex
CREATE INDEX "fvs_results_user_id_created_at_idx" ON "fvs_results"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "fvs_indicator_results_fvs_result_id_idx" ON "fvs_indicator_results"("fvs_result_id");

-- CreateIndex
CREATE INDEX "simulation_results_user_id_idx" ON "simulation_results"("user_id");

-- CreateIndex
CREATE INDEX "simulation_results_user_id_type_idx" ON "simulation_results"("user_id", "type");

-- CreateIndex
CREATE INDEX "simulation_results_user_id_created_at_idx" ON "simulation_results"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "recommendation_results_user_id_idx" ON "recommendation_results"("user_id");

-- CreateIndex
CREATE INDEX "recommendation_results_user_id_is_dismissed_idx" ON "recommendation_results"("user_id", "is_dismissed");

-- CreateIndex
CREATE INDEX "recommendation_results_user_id_created_at_idx" ON "recommendation_results"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "expense_anomalies_user_id_idx" ON "expense_anomalies"("user_id");

-- CreateIndex
CREATE INDEX "expense_anomalies_user_id_severity_idx" ON "expense_anomalies"("user_id", "severity");

-- CreateIndex
CREATE INDEX "expense_anomalies_user_id_created_at_idx" ON "expense_anomalies"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "expense_anomalies_expense_id_idx" ON "expense_anomalies"("expense_id");

-- CreateIndex
CREATE INDEX "notifications_user_id_idx" ON "notifications"("user_id");

-- CreateIndex
CREATE INDEX "notifications_user_id_is_read_idx" ON "notifications"("user_id", "is_read");

-- CreateIndex
CREATE INDEX "notifications_user_id_created_at_idx" ON "notifications"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "literacy_modules_category_idx" ON "literacy_modules"("category");

-- CreateIndex
CREATE INDEX "literacy_modules_difficulty_idx" ON "literacy_modules"("difficulty");

-- CreateIndex
CREATE INDEX "literacy_modules_is_published_order_idx" ON "literacy_modules"("is_published", "order");

-- CreateIndex
CREATE INDEX "savings_vaults_user_id_idx" ON "savings_vaults"("user_id");

-- CreateIndex
CREATE INDEX "savings_vaults_user_id_deleted_at_idx" ON "savings_vaults"("user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "savings_vaults_user_id_is_completed_idx" ON "savings_vaults"("user_id", "is_completed");

-- CreateIndex
CREATE INDEX "community_posts_user_id_idx" ON "community_posts"("user_id");

-- CreateIndex
CREATE INDEX "community_posts_deleted_at_idx" ON "community_posts"("deleted_at");

-- CreateIndex
CREATE INDEX "community_posts_category_deleted_at_idx" ON "community_posts"("category", "deleted_at");

-- CreateIndex
CREATE INDEX "community_posts_created_at_idx" ON "community_posts"("created_at");

-- CreateIndex
CREATE INDEX "community_comments_post_id_idx" ON "community_comments"("post_id");

-- CreateIndex
CREATE INDEX "community_comments_user_id_idx" ON "community_comments"("user_id");

-- CreateIndex
CREATE INDEX "community_comments_post_id_deleted_at_idx" ON "community_comments"("post_id", "deleted_at");

-- CreateIndex
CREATE INDEX "reward_points_user_id_idx" ON "reward_points"("user_id");

-- CreateIndex
CREATE INDEX "reward_points_user_id_action_idx" ON "reward_points"("user_id", "action");

-- CreateIndex
CREATE INDEX "reward_points_user_id_created_at_idx" ON "reward_points"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "ml_jobs_user_id_idx" ON "ml_jobs"("user_id");

-- CreateIndex
CREATE INDEX "ml_jobs_user_id_job_type_idx" ON "ml_jobs"("user_id", "job_type");

-- CreateIndex
CREATE INDEX "ml_jobs_status_idx" ON "ml_jobs"("status");

-- CreateIndex
CREATE INDEX "audit_logs_user_id_idx" ON "audit_logs"("user_id");

-- CreateIndex
CREATE INDEX "audit_logs_entity_entity_id_idx" ON "audit_logs"("entity", "entity_id");

-- CreateIndex
CREATE INDEX "audit_logs_action_idx" ON "audit_logs"("action");

-- CreateIndex
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs"("created_at");

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "family_profiles" ADD CONSTRAINT "family_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incomes" ADD CONSTRAINT "incomes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debts" ADD CONSTRAINT "debts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dependents" ADD CONSTRAINT "dependents_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "protections" ADD CONSTRAINT "protections_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fvs_results" ADD CONSTRAINT "fvs_results_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fvs_indicator_results" ADD CONSTRAINT "fvs_indicator_results_fvs_result_id_fkey" FOREIGN KEY ("fvs_result_id") REFERENCES "fvs_results"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "simulation_results" ADD CONSTRAINT "simulation_results_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recommendation_results" ADD CONSTRAINT "recommendation_results_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_anomalies" ADD CONSTRAINT "expense_anomalies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_anomalies" ADD CONSTRAINT "expense_anomalies_expense_id_fkey" FOREIGN KEY ("expense_id") REFERENCES "expenses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "savings_vaults" ADD CONSTRAINT "savings_vaults_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_posts" ADD CONSTRAINT "community_posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_comments" ADD CONSTRAINT "community_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_comments" ADD CONSTRAINT "community_comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "community_posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reward_points" ADD CONSTRAINT "reward_points_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ml_jobs" ADD CONSTRAINT "ml_jobs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
