import type { Request, Response, NextFunction } from 'express';
import { notificationsService } from './notifications.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class NotificationsController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await notificationsService.list((req as AuthenticatedRequest).user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async markAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') {
        throw new Error('Invalid ID');
      }
      sendSuccess(res, await notificationsService.markAsRead(id, (req as AuthenticatedRequest).user.id), 'Notification marked as read');
    } catch (e) { next(e); }
  }

  async markAllAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      sendSuccess(res, await notificationsService.markAllAsRead((req as AuthenticatedRequest).user.id), 'All notifications marked as read');
    } catch (e) { next(e); }
  }
}

export const notificationsController = new NotificationsController();
