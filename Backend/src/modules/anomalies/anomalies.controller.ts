import type { Request, Response, NextFunction } from 'express';
import { anomaliesService } from './anomalies.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class AnomaliesController {
  async detect(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await anomaliesService.detect((req as AuthenticatedRequest).user.id), 'Anomaly detection completed');
    } catch (e) { next(e); }
  }

  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await anomaliesService.list((req as AuthenticatedRequest).user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await anomaliesService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }
}

export const anomaliesController = new AnomaliesController();
