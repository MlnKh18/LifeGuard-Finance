import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateVaultInput, UpdateVaultInput } from './vaults.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class VaultsService {
  async list(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.savingsVault.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.savingsVault.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async getById(id: string, userId: string) {
    const v = await prisma.savingsVault.findUnique({ where: { id } });
    if (!v || v.userId !== userId) throw AppError.notFound('Vault not found');
    return v;
  }

  async create(userId: string, data: CreateVaultInput) {
    return prisma.savingsVault.create({
      data: { userId, ...data, deadline: data.deadline ? new Date(data.deadline) : null },
    });
  }

  async update(id: string, userId: string, data: UpdateVaultInput) {
    await this.getById(id, userId);
    const updated = await prisma.savingsVault.update({
      where: { id },
      data: {
        ...data,
        deadline: data.deadline ? new Date(data.deadline) : undefined,
      },
    });

    if (data.currentAmount !== undefined && updated.currentAmount >= updated.targetAmount && !updated.isCompleted) {
      return prisma.savingsVault.update({ where: { id }, data: { isCompleted: true, completedAt: new Date() } });
    }
    return updated;
  }

  async delete(id: string, userId: string) {
    await this.getById(id, userId);
    return prisma.savingsVault.update({ where: { id }, data: { deletedAt: new Date() } });
  }
}

export const vaultsService = new VaultsService();
