import { prisma } from '@shared/prisma/client.js';
import type { CreateProfileInput, UpdateProfileInput } from './profiles.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class ProfilesRepository {
  async findMany(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.familyProfile.findMany({
        where: { userId },
        skip: pagination.skip,
        take: pagination.take,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.familyProfile.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async findById(id: string) {
    return prisma.familyProfile.findUnique({ where: { id } });
  }

  async create(userId: string, data: CreateProfileInput) {
    return prisma.familyProfile.create({
      data: {
        userId,
        ...data,
        dateOfBirth: data.dateOfBirth ? new Date(data.dateOfBirth) : null,
      },
    });
  }

  async update(id: string, data: UpdateProfileInput) {
    return prisma.familyProfile.update({
      where: { id },
      data: {
        ...data,
        dateOfBirth: data.dateOfBirth ? new Date(data.dateOfBirth) : undefined,
      },
    });
  }

  async softDelete(id: string) {
    return prisma.familyProfile.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}

export const profilesRepository = new ProfilesRepository();
