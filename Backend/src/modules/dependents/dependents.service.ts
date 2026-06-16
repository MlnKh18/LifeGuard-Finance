import { dependentsRepository } from './dependents.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateDependentInput, UpdateDependentInput } from './dependents.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class DependentsService {
  async list(userId: string, pagination: PaginationParams) { return dependentsRepository.findMany(userId, pagination); }
  async getById(id: string, userId: string) { const d = await dependentsRepository.findById(id); if (!d || d.userId !== userId) throw AppError.notFound('Dependent not found'); return d; }
  async create(userId: string, data: CreateDependentInput) { return dependentsRepository.create(userId, data); }
  async update(id: string, userId: string, data: UpdateDependentInput) { await this.getById(id, userId); return dependentsRepository.update(id, data); }
  async delete(id: string, userId: string) { await this.getById(id, userId); return dependentsRepository.softDelete(id); }
}

export const dependentsService = new DependentsService();
