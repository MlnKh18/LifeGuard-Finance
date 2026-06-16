import { protectionsRepository } from './protections.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateProtectionInput, UpdateProtectionInput } from './protections.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class ProtectionsService {
  async list(userId: string, pagination: PaginationParams, filters?: { type?: string }) { return protectionsRepository.findMany(userId, pagination, filters); }
  async getById(id: string, userId: string) { const p = await protectionsRepository.findById(id); if (!p || p.userId !== userId) throw AppError.notFound('Protection not found'); return p; }
  async create(userId: string, data: CreateProtectionInput) { return protectionsRepository.create(userId, data); }
  async update(id: string, userId: string, data: UpdateProtectionInput) { await this.getById(id, userId); return protectionsRepository.update(id, data); }
  async delete(id: string, userId: string) { await this.getById(id, userId); return protectionsRepository.softDelete(id); }
}

export const protectionsService = new ProtectionsService();
