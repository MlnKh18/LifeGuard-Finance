import type { Request, Response, NextFunction } from 'express';
import { fvsService } from './fvs.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class FvsController {
  async calculate(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await fvsService.calculate((req as AuthenticatedRequest).user.id);
      sendCreated(res, result, 'FVS calculated successfully');
    } catch (e) { next(e); }
  }

  async getHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await fvsService.getHistory((req as AuthenticatedRequest).user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getLatest(req: Request, res: Response, next: NextFunction) {
    try { sendSuccess(res, await fvsService.getLatest((req as AuthenticatedRequest).user.id)); } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await fvsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }
}

export const fvsController = new FvsController();
