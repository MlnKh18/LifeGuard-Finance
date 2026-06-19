/*
  Warnings:

  - The values [USER,MODERATOR] on the enum `Role` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `icon_url` on the `savings_vaults` table. All the data in the column will be lost.
  - You are about to drop the column `user_id` on the `savings_vaults` table. All the data in the column will be lost.
  - Added the required column `owner_user_id` to the `savings_vaults` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "VaultScope" AS ENUM ('FAMILY', 'PERSONAL');

-- CreateEnum
CREATE TYPE "VaultPriority" AS ENUM ('HIGH', 'MEDIUM', 'LOW');

-- CreateEnum
CREATE TYPE "SavingFrequency" AS ENUM ('WEEKLY', 'MONTHLY', 'YEARLY');

-- CreateEnum
CREATE TYPE "InvitationStatus" AS ENUM ('PENDING', 'ACCEPTED', 'EXPIRED');

-- AlterEnum
BEGIN;
CREATE TYPE "Role_new" AS ENUM ('HEAD_OF_FAMILY', 'FAMILY_MEMBER', 'ADMIN');
ALTER TABLE "public"."user_roles" ALTER COLUMN "role" DROP DEFAULT;
ALTER TABLE "user_roles" ALTER COLUMN "role" TYPE "Role_new" USING ("role"::text::"Role_new");
ALTER TYPE "Role" RENAME TO "Role_old";
ALTER TYPE "Role_new" RENAME TO "Role";
DROP TYPE "public"."Role_old";
ALTER TABLE "user_roles" ALTER COLUMN "role" SET DEFAULT 'FAMILY_MEMBER';
COMMIT;

-- DropForeignKey
ALTER TABLE "savings_vaults" DROP CONSTRAINT "savings_vaults_user_id_fkey";

-- DropIndex
DROP INDEX "savings_vaults_user_id_deleted_at_idx";

-- DropIndex
DROP INDEX "savings_vaults_user_id_idx";

-- DropIndex
DROP INDEX "savings_vaults_user_id_is_completed_idx";

-- AlterTable
ALTER TABLE "reward_points" ADD COLUMN     "source_id" TEXT;

-- AlterTable
ALTER TABLE "savings_vaults" DROP COLUMN "icon_url",
DROP COLUMN "user_id",
ADD COLUMN     "icon_name" TEXT,
ADD COLUMN     "owner_email" TEXT,
ADD COLUMN     "owner_user_id" UUID NOT NULL,
ADD COLUMN     "periodic_target_amount" DECIMAL(15,2),
ADD COLUMN     "priority" "VaultPriority" NOT NULL DEFAULT 'MEDIUM',
ADD COLUMN     "saving_frequency" "SavingFrequency" NOT NULL DEFAULT 'MONTHLY',
ADD COLUMN     "scope" "VaultScope" NOT NULL DEFAULT 'PERSONAL';

-- AlterTable
ALTER TABLE "user_roles" ALTER COLUMN "role" SET DEFAULT 'FAMILY_MEMBER';

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "family_code" TEXT,
ADD COLUMN     "family_id" UUID;

-- CreateTable
CREATE TABLE "family_invitations" (
    "id" UUID NOT NULL,
    "family_code" TEXT NOT NULL,
    "invite_code" TEXT NOT NULL,
    "invited_email" TEXT NOT NULL,
    "relation" TEXT NOT NULL,
    "status" "InvitationStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "family_invitations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "family_invitations_invite_code_key" ON "family_invitations"("invite_code");

-- CreateIndex
CREATE INDEX "family_invitations_family_code_idx" ON "family_invitations"("family_code");

-- CreateIndex
CREATE INDEX "family_invitations_invite_code_idx" ON "family_invitations"("invite_code");

-- CreateIndex
CREATE INDEX "savings_vaults_owner_user_id_idx" ON "savings_vaults"("owner_user_id");

-- CreateIndex
CREATE INDEX "savings_vaults_owner_user_id_deleted_at_idx" ON "savings_vaults"("owner_user_id", "deleted_at");

-- CreateIndex
CREATE INDEX "savings_vaults_owner_user_id_is_completed_idx" ON "savings_vaults"("owner_user_id", "is_completed");

-- AddForeignKey
ALTER TABLE "savings_vaults" ADD CONSTRAINT "savings_vaults_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
