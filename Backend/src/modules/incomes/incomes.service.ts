import { incomesRepository } from './incomes.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateIncomeInput, UpdateIncomeInput } from './incomes.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class IncomesService {
  async list(userId: string, pagination: PaginationParams, filters?: { frequency?: string }) {
    return incomesRepository.findMany(userId, pagination, filters);
  }

  async getById(id: string, userId: string) {
    const income = await incomesRepository.findById(id);
    if (!income || income.userId !== userId) throw AppError.notFound('Income not found');
    return income;
  }

  async create(userId: string, data: CreateIncomeInput) { return incomesRepository.create(userId, data); }

  async update(id: string, userId: string, data: UpdateIncomeInput) {
    await this.getById(id, userId);
    return incomesRepository.update(id, data);
  }

  async delete(id: string, userId: string) {
    await this.getById(id, userId);
    return incomesRepository.softDelete(id);
  }
}

export const incomesService = new IncomesService();
