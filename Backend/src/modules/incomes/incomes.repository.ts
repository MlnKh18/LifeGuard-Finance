import { prisma } from '@shared/prisma/client.js';
import type { CreateIncomeInput, UpdateIncomeInput } from './incomes.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class IncomesRepository {
  async findMany(userId: string, pagination: PaginationParams, filters?: { frequency?: string }) {
    const where: any = { userId };
    if (filters?.frequency) where.frequency = filters.frequency;

    const [data, total] = await Promise.all([
      prisma.income.findMany({ where, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.income.count({ where }),
    ]);
    return { data, total };
  }

  async findById(id: string) { return prisma.income.findUnique({ where: { id } }); }

  async create(userId: string, data: CreateIncomeInput) {
    return prisma.income.create({
      data: {
        userId, source: data.source, amount: data.amount, currency: data.currency ?? 'IDR',
        frequency: data.frequency, description: data.description,
        isActive: data.isActive ?? true,
        startDate: data.startDate ? new Date(data.startDate) : null,
        endDate: data.endDate ? new Date(data.endDate) : null,
      },
    });
  }

  async update(id: string, data: UpdateIncomeInput) {
    return prisma.income.update({
      where: { id },
      data: {
        ...data,
        startDate: data.startDate ? new Date(data.startDate) : undefined,
        endDate: data.endDate ? new Date(data.endDate) : undefined,
      },
    });
  }

  async softDelete(id: string) { return prisma.income.update({ where: { id }, data: { deletedAt: new Date() } }); }

  async findAllByUserId(userId: string) {
    return prisma.income.findMany({ where: { userId, isActive: true } });
  }
}

export const incomesRepository = new IncomesRepository();
