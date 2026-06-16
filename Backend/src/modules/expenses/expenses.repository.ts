import { prisma } from '@shared/prisma/client.js';
import type { CreateExpenseInput, UpdateExpenseInput } from './expenses.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class ExpensesRepository {
  async findMany(userId: string, pagination: PaginationParams, filters?: { category?: string; startDate?: string; endDate?: string }) {
    const where: any = { userId };
    if (filters?.category) where.category = filters.category;
    if (filters?.startDate || filters?.endDate) {
      where.date = {};
      if (filters?.startDate) where.date.gte = new Date(filters.startDate);
      if (filters?.endDate) where.date.lte = new Date(filters.endDate);
    }

    const [data, total] = await Promise.all([
      prisma.expense.findMany({ where, skip: pagination.skip, take: pagination.take, orderBy: { date: 'desc' } }),
      prisma.expense.count({ where }),
    ]);
    return { data, total };
  }

  async findById(id: string) { return prisma.expense.findUnique({ where: { id } }); }

  async create(userId: string, data: CreateExpenseInput) {
    return prisma.expense.create({
      data: {
        userId, category: data.category, amount: data.amount,
        currency: data.currency ?? 'IDR', description: data.description,
        date: data.date ? new Date(data.date) : new Date(),
        isRecurring: data.isRecurring ?? false,
      },
    });
  }

  async update(id: string, data: UpdateExpenseInput) {
    return prisma.expense.update({
      where: { id },
      data: { ...data, date: data.date ? new Date(data.date) : undefined },
    });
  }

  async softDelete(id: string) { return prisma.expense.update({ where: { id }, data: { deletedAt: new Date() } }); }

  async findAllByUserId(userId: string) { return prisma.expense.findMany({ where: { userId } }); }
}

export const expensesRepository = new ExpensesRepository();
