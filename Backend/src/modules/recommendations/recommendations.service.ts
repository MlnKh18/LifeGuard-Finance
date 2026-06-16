import { prisma } from '@shared/prisma/client.js';
import { incomesRepository } from '@modules/incomes/incomes.repository.js';
import { expensesRepository } from '@modules/expenses/expenses.repository.js';
import { debtsRepository } from '@modules/debts/debts.repository.js';
import { protectionsRepository } from '@modules/protections/protections.repository.js';
import { fvsRepository } from '@modules/fvs/fvs.repository.js';
import { mlAdapter } from '@modules/ml/ml.adapter.js';
import { buildRecommendationPayload } from '@modules/ml/ml.payload-builder.js';
import { AppError } from '@shared/utils/app-error.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class RecommendationsService {
  async list(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.recommendationResult.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: [{ priority: 'desc' }, { createdAt: 'desc' }] }),
      prisma.recommendationResult.count({ where: { userId } }),
    ]);

    if (total === 0) {
      await this.generateRecommendations(userId);
      const refreshed = await prisma.recommendationResult.findMany({ where: { userId }, orderBy: [{ priority: 'desc' }, { createdAt: 'desc' }] });
      return { data: refreshed, total: refreshed.length };
    }

    return { data, total };
  }

  async getById(id: string, userId: string) {
    const r = await prisma.recommendationResult.findUnique({ where: { id } });
    if (!r || r.userId !== userId) throw AppError.notFound('Recommendation not found');
    return r;
  }

  private async generateRecommendations(userId: string) {
    const latestFvs = await fvsRepository.findLatest(userId);
    if (!latestFvs) throw AppError.badRequest('Please calculate your FVS first before getting recommendations');

    const [incomes, expenses, debts, protections] = await Promise.all([
      incomesRepository.findAllByUserId(userId),
      expensesRepository.findAllByUserId(userId),
      debtsRepository.findAllByUserId(userId),
      protectionsRepository.findAllByUserId(userId),
    ]);

    const payload = buildRecommendationPayload(userId, latestFvs, incomes, expenses, debts, protections);
    const mlResult = await mlAdapter.generateRecommendations(payload);

    await prisma.recommendationResult.createMany({
      data: mlResult.recommendations.map((r) => ({
        userId,
        category: r.category,
        title: r.title,
        description: r.description,
        priority: r.priority,
        actionUrl: r.actionUrl,
        metadata: (r.metadata ?? undefined) as any,
      })),
    });
  }
}

export const recommendationsService = new RecommendationsService();
