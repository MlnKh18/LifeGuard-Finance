import { prisma } from '@shared/prisma/client.js';
import type { CreateDependentInput, UpdateDependentInput } from './dependents.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class DependentsRepository {
  async findMany(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.dependent.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.dependent.count({ where: { userId } }),
    ]);
    return { data, total };
  }
  async findById(id: string) { return prisma.dependent.findUnique({ where: { id } }); }
  async create(userId: string, data: CreateDependentInput) {
    return prisma.dependent.create({ data: { userId, ...data, dateOfBirth: data.dateOfBirth ? new Date(data.dateOfBirth) : null } });
  }
  async update(id: string, data: UpdateDependentInput) {
    return prisma.dependent.update({ where: { id }, data: { ...data, dateOfBirth: data.dateOfBirth ? new Date(data.dateOfBirth) : undefined } });
  }
  async softDelete(id: string) { return prisma.dependent.update({ where: { id }, data: { deletedAt: new Date() } }); }
  async findAllByUserId(userId: string) { return prisma.dependent.findMany({ where: { userId } }); }
}

export const dependentsRepository = new DependentsRepository();
