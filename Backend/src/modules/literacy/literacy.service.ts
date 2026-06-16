import { prisma } from '@shared/prisma/client.js';
import { cache } from '@shared/utils/cache.js';
import { CACHE_TTL } from '@shared/constants/index.js';
import { AppError } from '@shared/utils/app-error.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class LiteracyService {
  async list(pagination: PaginationParams, filters?: { category?: string; difficulty?: string }) {
    const cacheKey = `literacy:${pagination.page}:${pagination.limit}:${filters?.category ?? ''}:${filters?.difficulty ?? ''}`;

    return cache.getOrSet(cacheKey, async () => {
      const where: any = { isPublished: true };
      if (filters?.category) where.category = filters.category;
      if (filters?.difficulty) where.difficulty = filters.difficulty;

      const [data, total] = await Promise.all([
        prisma.literacyModule.findMany({ where, skip: pagination.skip, take: pagination.take, orderBy: { order: 'asc' } }),
        prisma.literacyModule.count({ where }),
      ]);
      return { data, total };
    }, CACHE_TTL.LITERACY_MODULES);
  }

  async getById(id: string) {
    const cacheKey = `literacy:${id}`;
    return cache.getOrSet(cacheKey, async () => {
      const module = await prisma.literacyModule.findUnique({ where: { id } });
      if (!module) throw AppError.notFound('Literacy module not found');
      return module;
    }, CACHE_TTL.LITERACY_MODULES);
  }
}

export const literacyService = new LiteracyService();
