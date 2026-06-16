import type { Request, Response, NextFunction } from 'express';
import { dependentsService } from './dependents.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class DependentsController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const a = req as AuthenticatedRequest;
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await dependentsService.list(a.user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await dependentsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await dependentsService.create((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await dependentsService.update(id, (req as AuthenticatedRequest).user.id, req.body), 'Dependent updated successfully');
    } catch (e) { next(e); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await dependentsService.delete(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Dependent deleted successfully');
    } catch (e) { next(e); }
  }
}

export const dependentsController = new DependentsController();
