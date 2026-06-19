import { prisma } from '@shared/prisma/client.js';
import type { PaginationParams } from '@shared/utils/pagination.js';
import { RewardAction } from '@prisma/client';

export class RewardsService {
  async addRewardPoint(userId: string, action: RewardAction, points: number, sourceId?: string) {
    if (sourceId) {
      const existing = await prisma.rewardPoint.findFirst({
        where: { userId, action, sourceId }
      });
      if (existing) return existing;
    }

    return prisma.rewardPoint.create({
      data: {
        userId,
        action,
        points,
        sourceId
      }
    });
  }
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
