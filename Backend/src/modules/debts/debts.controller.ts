import type { Request, Response, NextFunction } from 'express';
import { debtsService } from './debts.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class DebtsController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const a = req as AuthenticatedRequest;
      const p = parsePagination(req.query as Record<string, unknown>);
      const status = typeof req.query.status === 'string' ? req.query.status : undefined;
      const { data, total } = await debtsService.list(a.user.id, p, { status });
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await debtsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await debtsService.create((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await debtsService.update(id, (req as AuthenticatedRequest).user.id, req.body), 'Debt updated successfully');
    } catch (e) { next(e); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await debtsService.delete(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Debt deleted successfully');
    } catch (e) { next(e); }
  }
}

export const debtsController = new DebtsController();
