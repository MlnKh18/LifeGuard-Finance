import type { Request, Response, NextFunction } from 'express';
import { protectionsService } from './protections.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class ProtectionsController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const a = req as AuthenticatedRequest;
      const p = parsePagination(req.query as Record<string, unknown>);
      const type = typeof req.query.type === 'string' ? req.query.type : undefined;
      const { data, total } = await protectionsService.list(a.user.id, p, { type });
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await protectionsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await protectionsService.create((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await protectionsService.update(id, (req as AuthenticatedRequest).user.id, req.body), 'Protection updated successfully');
    } catch (e) { next(e); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await protectionsService.delete(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Protection deleted successfully');
    } catch (e) { next(e); }
  }
}

export const protectionsController = new ProtectionsController();
