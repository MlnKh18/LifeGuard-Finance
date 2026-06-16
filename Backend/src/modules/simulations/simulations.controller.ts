import type { Request, Response, NextFunction } from 'express';
import { simulationsService } from './simulations.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class SimulationsController {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await simulationsService.create((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await simulationsService.list((req as AuthenticatedRequest).user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await simulationsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await simulationsService.delete(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Simulation deleted successfully');
    } catch (e) { next(e); }
  }
}

export const simulationsController = new SimulationsController();
