import { prisma } from '@shared/prisma/client.js';
import type { FvsCategory } from '@prisma/client';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class FvsRepository {
  async findMany(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.fvsResult.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' }, include: { indicators: true } }),
      prisma.fvsResult.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async findById(id: string) {
    return prisma.fvsResult.findUnique({ where: { id }, include: { indicators: true } });
  }

  async findLatest(userId: string) {
    return prisma.fvsResult.findFirst({ where: { userId }, orderBy: { createdAt: 'desc' }, include: { indicators: true } });
  }

  async create(data: {
    userId: string;
    score: number;
    category: FvsCategory;
    modelVersion: string;
    rawResponse: any;
    indicators: Array<{ indicatorName: string; value: number; weight: number; status: string; description?: string }>;
  }) {
    return prisma.fvsResult.create({
      data: {
        userId: data.userId,
        score: data.score,
        category: data.category,
        modelVersion: data.modelVersion,
        rawResponse: data.rawResponse,
        indicators: {
          create: data.indicators,
        },
      },
      include: { indicators: true },
    });
  }
}

export const fvsRepository = new FvsRepository();
