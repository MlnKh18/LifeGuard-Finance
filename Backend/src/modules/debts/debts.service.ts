import { debtsRepository } from './debts.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateDebtInput, UpdateDebtInput } from './debts.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class DebtsService {
  async list(userId: string, pagination: PaginationParams, filters?: { status?: string }) { return debtsRepository.findMany(userId, pagination, filters); }
  async getById(id: string, userId: string) { const d = await debtsRepository.findById(id); if (!d || d.userId !== userId) throw AppError.notFound('Debt not found'); return d; }
  async create(userId: string, data: CreateDebtInput) { return debtsRepository.create(userId, data); }
  async update(id: string, userId: string, data: UpdateDebtInput) { await this.getById(id, userId); return debtsRepository.update(id, data); }
  async delete(id: string, userId: string) { await this.getById(id, userId); return debtsRepository.softDelete(id); }
}

export const debtsService = new DebtsService();
