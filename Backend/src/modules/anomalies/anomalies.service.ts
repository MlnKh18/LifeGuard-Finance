import { prisma } from '@shared/prisma/client.js';
import { expensesRepository } from '@modules/expenses/expenses.repository.js';
import { mlAdapter } from '@modules/ml/ml.adapter.js';
import { buildAnomalyPayload } from '@modules/ml/ml.payload-builder.js';
import { AppError } from '@shared/utils/app-error.js';
import type { AnomalySeverity } from '@prisma/client';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class AnomaliesService {
  async detect(userId: string) {
    const expenses = await expensesRepository.findAllByUserId(userId);
    if (expenses.length === 0) throw AppError.badRequest('No expenses found to analyze');

    const payload = buildAnomalyPayload(userId, expenses);
    const mlResult = await mlAdapter.detectAnomalies(payload);

    if (mlResult.anomalies.length > 0) {
      await prisma.expenseAnomaly.createMany({
        data: mlResult.anomalies.map((a) => ({
          userId,
          expenseId: a.expenseId ?? null,
          type: a.type,
          severity: a.severity as AnomalySeverity,
          description: a.description,
          amount: a.amount ?? null,
          expectedRange: (a.expectedRange ?? undefined) as any,
          metadata: (a.metadata ?? undefined) as any,
        })),
      });
    }

    return { anomaliesFound: mlResult.anomalies.length, anomalies: mlResult.anomalies };
  }

  async list(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.expenseAnomaly.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' }, include: { expense: true } }),
      prisma.expenseAnomaly.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async getById(id: string, userId: string) {
    const a = await prisma.expenseAnomaly.findUnique({ where: { id }, include: { expense: true } });
    if (!a || a.userId !== userId) throw AppError.notFound('Anomaly not found');
    return a;
  }
}

export const anomaliesService = new AnomaliesService();
