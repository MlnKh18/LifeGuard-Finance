import { fvsRepository } from './fvs.repository.js';
import { incomesRepository } from '@modules/incomes/incomes.repository.js';
import { expensesRepository } from '@modules/expenses/expenses.repository.js';
import { debtsRepository } from '@modules/debts/debts.repository.js';
import { dependentsRepository } from '@modules/dependents/dependents.repository.js';
import { protectionsRepository } from '@modules/protections/protections.repository.js';
import { mlAdapter } from '@modules/ml/ml.adapter.js';
import { buildFvsPayload } from '@modules/ml/ml.payload-builder.js';
import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { FvsCategory } from '@prisma/client';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class FvsService {
  async calculate(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw AppError.notFound('User not found');

    const [incomes, expenses, debts, dependents, protections] = await Promise.all([
      incomesRepository.findAllByUserId(userId),
      expensesRepository.findAllByUserId(userId),
      debtsRepository.findAllByUserId(userId),
      dependentsRepository.findAllByUserId(userId),
      protectionsRepository.findAllByUserId(userId),
    ]);

    const payload = buildFvsPayload(user, incomes, expenses, debts, dependents, protections);

    const mlJob = await prisma.mlJob.create({
      data: { userId, jobType: 'FVS_CALCULATION', status: 'PROCESSING', requestPayload: payload as any, startedAt: new Date() },
    });

    try {
      const mlResult = await mlAdapter.calculateFvs(payload);

      await prisma.mlJob.update({
        where: { id: mlJob.id },
        data: { status: 'COMPLETED', responsePayload: mlResult as any, completedAt: new Date() },
      });

      const categoryStr = mlResult.data.category.toUpperCase().replace(/\s+/g, '_') as FvsCategory;
      const fvsResult = await fvsRepository.create({
        userId,
        score: mlResult.data.score,
        category: categoryStr,
        modelVersion: mlResult.model_version,
        rawResponse: mlResult as any,
        indicators: Object.entries(mlResult.data.indicators).map(([key, value]) => ({
          indicatorName: key,
          value: value,
          weight: mlResult.data.feature_importance[key] ?? 0,
          status: 'COMPUTED',
          description: null as any,
        })),
      });

      return fvsResult;
    } catch (error) {
      await prisma.mlJob.update({
        where: { id: mlJob.id },
        data: { status: 'FAILED', errorMessage: error instanceof Error ? error.message : 'Unknown error', completedAt: new Date() },
      });
      throw error;
    }
  }

  async getHistory(userId: string, pagination: PaginationParams) {
    return fvsRepository.findMany(userId, pagination);
  }

  async getLatest(userId: string) {
    const result = await fvsRepository.findLatest(userId);
    if (!result) throw AppError.notFound('No FVS results found. Please calculate your FVS first.');
    return result;
  }

  async getById(id: string, userId: string) {
    const result = await fvsRepository.findById(id);
    if (!result || result.userId !== userId) throw AppError.notFound('FVS result not found');
    return result;
  }
}

export const fvsService = new FvsService();
