import type { Request, Response, NextFunction } from 'express';
import { recommendationsService } from './recommendations.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class RecommendationsController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await recommendationsService.list((req as AuthenticatedRequest).user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await recommendationsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }
}

export const recommendationsController = new RecommendationsController();
