import { prisma } from '@shared/prisma/client.js';
import { Role } from '@prisma/client';

export class SummaryService {
  async getProfileSummary(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        roles: true,
        fvsResults: { orderBy: { createdAt: 'desc' }, take: 1 },
      }
    });

    if (!user) throw new Error('User not found');

    const totalSavingsResult = await prisma.savingsVault.aggregate({
      where: { ownerUserId: userId },
      _sum: { currentAmount: true }
    });

    const postsCount = await prisma.communityPost.count({
      where: { userId }
    });

    const isHead = user.roles.some((r) => r.role === Role.HEAD_OF_FAMILY);

    return {
      displayName: user.displayName,
      email: user.email,
      roles: user.roles.map(r => r.role),
      financialStatus: user.fvsResults[0]?.category || 'UNKNOWN',
      totalSavings: totalSavingsResult._sum.currentAmount || 0,
      literacyProgress: 0, // Placeholder as literacy tracking isn't fully defined yet
      communityPostsCount: postsCount,
      permissions: {
        canAccessCommunity: isHead,
        canManageFamily: isHead,
      }
    };
  }

  async getDashboardSummary(userId: string) {
    const latestFvs = await prisma.fvsResult.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    const topRecommendation = await prisma.recommendationResult.findFirst({
      where: { userId, isDismissed: false },
      orderBy: { priority: 'desc' },
    });

    const unreadNotifications = await prisma.notification.count({
      where: { userId, isRead: false },
    });

    const activeVaults = await prisma.savingsVault.findMany({
      where: { ownerUserId: userId, isCompleted: false },
      take: 3,
      orderBy: { createdAt: 'desc' },
    });

    return {
      latestFvs,
      topRecommendation,
      unreadNotifications,
      activeVaults,
    };
  }
}

export const summaryService = new SummaryService();
