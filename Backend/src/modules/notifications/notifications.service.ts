import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class NotificationsService {
  async list(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.notification.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' } }),
      prisma.notification.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async markAsRead(id: string, userId: string) {
    const n = await prisma.notification.findUnique({ where: { id } });
    if (!n || n.userId !== userId) throw AppError.notFound('Notification not found');
    return prisma.notification.update({ where: { id }, data: { isRead: true, readAt: new Date() } });
  }

  async markAllAsRead(userId: string) {
    await prisma.notification.updateMany({ where: { userId, isRead: false }, data: { isRead: true, readAt: new Date() } });
    return { message: 'All notifications marked as read' };
  }
}

export const notificationsService = new NotificationsService();
