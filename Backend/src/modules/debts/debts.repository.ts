import { prisma } from '@shared/prisma/client.js';
import type { CreateDebtInput, UpdateDebtInput } from './debts.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class DebtsRepository {
  async findMany(userId: string, pagination: PaginationParams, filters?: { status?: string }) {
    const where: any = { userId };
    if (filters?.status) where.status = filters.status;
    const [data, total] = await Promise.all([
      prisma.debt.findMany({ where, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.debt.count({ where }),
    ]);
    return { data, total };
  }

  async findById(id: string) { return prisma.debt.findUnique({ where: { id } }); }

  async create(userId: string, data: CreateDebtInput) {
    return prisma.debt.create({
      data: { userId, ...data, startDate: data.startDate ? new Date(data.startDate) : null, dueDate: data.dueDate ? new Date(data.dueDate) : null },
    });
  }

  async update(id: string, data: UpdateDebtInput) {
    return prisma.debt.update({
      where: { id },
      data: { ...data, startDate: data.startDate ? new Date(data.startDate) : undefined, dueDate: data.dueDate ? new Date(data.dueDate) : undefined },
    });
  }

  async softDelete(id: string) { return prisma.debt.update({ where: { id }, data: { deletedAt: new Date() } }); }
  async findAllByUserId(userId: string) { return prisma.debt.findMany({ where: { userId } }); }
}

export const debtsRepository = new DebtsRepository();
