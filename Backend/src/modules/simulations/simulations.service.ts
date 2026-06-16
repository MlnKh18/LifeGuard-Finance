import { prisma } from '@shared/prisma/client.js';
import { incomesRepository } from '@modules/incomes/incomes.repository.js';
import { expensesRepository } from '@modules/expenses/expenses.repository.js';
import { debtsRepository } from '@modules/debts/debts.repository.js';
import { protectionsRepository } from '@modules/protections/protections.repository.js';
import { fvsRepository } from '@modules/fvs/fvs.repository.js';
import { mlAdapter } from '@modules/ml/ml.adapter.js';
import { buildSimulationPayload } from '@modules/ml/ml.payload-builder.js';
import { AppError } from '@shared/utils/app-error.js';
import type { SimulationType } from '@prisma/client';
import type { CreateSimulationInput } from './simulations.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class SimulationsService {
  async create(userId: string, data: CreateSimulationInput) {
    const [incomes, expenses, debts, protections, latestFvs] = await Promise.all([
      incomesRepository.findAllByUserId(userId),
      expensesRepository.findAllByUserId(userId),
      debtsRepository.findAllByUserId(userId),
      protectionsRepository.findAllByUserId(userId),
      fvsRepository.findLatest(userId),
    ]);

    const totalIncome = incomes.reduce((sum, i) => sum + Number(i.amount), 0);
    const totalExpenses = expenses.reduce((sum, e) => sum + Number(e.amount), 0);
    const totalDebt = debts.reduce((sum, d) => sum + Number(d.remainingBalance), 0);
    const totalProtection = protections.reduce((sum, p) => sum + Number(p.coverageAmount), 0);

    const payload = buildSimulationPayload(userId, data.type, data.parameters, {
      totalIncome, totalExpenses, totalDebt, totalProtection,
      fvsScore: latestFvs ? Number(latestFvs.score) : undefined,
    });

    const mlResult = await mlAdapter.runSimulation(payload);

    return prisma.simulationResult.create({
      data: {
        userId,
        type: data.type as SimulationType,
        title: data.title ?? mlResult.title,
        parameters: data.parameters as any,
        result: mlResult.result as any,
        modelVersion: mlResult.modelVersion,
      },
    });
  }

  async list(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.simulationResult.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.simulationResult.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async getById(id: string, userId: string) {
    const s = await prisma.simulationResult.findUnique({ where: { id } });
    if (!s || s.userId !== userId) throw AppError.notFound('Simulation not found');
    return s;
  }

  async delete(id: string, userId: string) {
    await this.getById(id, userId);
    return prisma.simulationResult.update({ where: { id }, data: { deletedAt: new Date() } });
  }
}

export const simulationsService = new SimulationsService();
