import type { Request, Response, NextFunction } from 'express';
import { literacyService } from './literacy.service.js';
import { sendSuccess, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class LiteracyController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const filters = {
        category: typeof req.query.category === 'string' ? req.query.category : undefined,
        difficulty: typeof req.query.difficulty === 'string' ? req.query.difficulty : undefined
      };
      const { data, total } = await literacyService.list(p, filters);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') {
        throw new Error('Invalid ID');
      }
      sendSuccess(res, await literacyService.getById(id));
    } catch (e) { next(e); }
  }
}

export const literacyController = new LiteracyController();
