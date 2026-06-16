import { prisma } from '@shared/prisma/client.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class RewardsService {
  async getSummary(userId: string) {
    const result = await prisma.rewardPoint.aggregate({
      where: { userId },
      _sum: { points: true },
      _count: true,
    });

    const recentRewards = await prisma.rewardPoint.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    return {
      totalPoints: result._sum.points ?? 0,
      totalActions: result._count,
      recentRewards,
    };
  }

  async getHistory(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.rewardPoint.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.rewardPoint.count({ where: { userId } }),
    ]);
    return { data, total };
  }
}

export const rewardsService = new RewardsService();
