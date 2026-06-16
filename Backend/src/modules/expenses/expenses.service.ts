import { expensesRepository } from './expenses.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateExpenseInput, UpdateExpenseInput } from './expenses.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class ExpensesService {
  async list(userId: string, pagination: PaginationParams, filters?: { category?: string; startDate?: string; endDate?: string }) {
    return expensesRepository.findMany(userId, pagination, filters);
  }

  async getById(id: string, userId: string) {
    const expense = await expensesRepository.findById(id);
    if (!expense || expense.userId !== userId) throw AppError.notFound('Expense not found');
    return expense;
  }

  async create(userId: string, data: CreateExpenseInput) { return expensesRepository.create(userId, data); }

  async update(id: string, userId: string, data: UpdateExpenseInput) {
    await this.getById(id, userId);
    return expensesRepository.update(id, data);
  }

  async delete(id: string, userId: string) {
    await this.getById(id, userId);
    return expensesRepository.softDelete(id);
  }
}

export const expensesService = new ExpensesService();
