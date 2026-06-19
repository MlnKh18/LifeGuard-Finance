import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateVaultInput, UpdateVaultInput } from './vaults.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';
import { rewardsService } from '../rewards/rewards.service.js';

export class VaultsService {
  async list(ownerUserId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.savingsVault.findMany({ where: { ownerUserId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.savingsVault.count({ where: { ownerUserId } }),
    ]);
    return { data, total };
  }

  async getById(id: string, ownerUserId: string) {
    const v = await prisma.savingsVault.findUnique({ where: { id } });
    if (!v || v.ownerUserId !== ownerUserId) throw AppError.notFound('Vault not found');
    return v;
  }

  async create(ownerUserId: string, data: CreateVaultInput) {
    return prisma.savingsVault.create({
      data: { ownerUserId, ...data, deadline: data.deadline ? new Date(data.deadline) : null },
    });
  }

  async update(id: string, ownerUserId: string, data: UpdateVaultInput) {
    await this.getById(id, ownerUserId);
    const updated = await prisma.savingsVault.update({
      where: { id },
      data: {
        ...data,
        deadline: data.deadline ? new Date(data.deadline) : undefined,
      },
    });

    if (data.currentAmount !== undefined && updated.currentAmount >= updated.targetAmount && !updated.isCompleted) {
      const completedVault = await prisma.savingsVault.update({ where: { id }, data: { isCompleted: true, completedAt: new Date() } });
      await rewardsService.addRewardPoint(ownerUserId, 'VAULT_MILESTONE', 25, completedVault.id).catch(console.error);
      return completedVault;
    }
    return updated;
  }

  async delete(id: string, ownerUserId: string) {
    await this.getById(id, ownerUserId);
    return prisma.savingsVault.update({ where: { id }, data: { deletedAt: new Date() } });
  }
}

export const vaultsService = new VaultsService();
