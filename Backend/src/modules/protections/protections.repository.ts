import { prisma } from '@shared/prisma/client.js';
import type { CreateProtectionInput, UpdateProtectionInput } from './protections.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class ProtectionsRepository {
  async findMany(userId: string, pagination: PaginationParams, filters?: { type?: string }) {
    const where: any = { userId };
    if (filters?.type) where.type = filters.type;
    const [data, total] = await Promise.all([
      prisma.protection.findMany({ where, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.protection.count({ where }),
    ]);
    return { data, total };
  }
  async findById(id: string) { return prisma.protection.findUnique({ where: { id } }); }
  async create(userId: string, data: CreateProtectionInput) {
    return prisma.protection.create({
      data: { userId, ...data, startDate: data.startDate ? new Date(data.startDate) : null, expiryDate: data.expiryDate ? new Date(data.expiryDate) : null },
    });
  }
  async update(id: string, data: UpdateProtectionInput) {
    return prisma.protection.update({ where: { id }, data: { ...data, startDate: data.startDate ? new Date(data.startDate) : undefined, expiryDate: data.expiryDate ? new Date(data.expiryDate) : undefined } });
  }
  async softDelete(id: string) { return prisma.protection.update({ where: { id }, data: { deletedAt: new Date() } }); }
  async findAllByUserId(userId: string) { return prisma.protection.findMany({ where: { userId, isActive: true } }); }
}

export const protectionsRepository = new ProtectionsRepository();
