import type { Request, Response, NextFunction } from 'express';
import { incomesService } from './incomes.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class IncomesController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const pagination = parsePagination(req.query as Record<string, unknown>);
      const frequency = typeof req.query.frequency === 'string' ? req.query.frequency : undefined;
      const { data, total } = await incomesService.list(authReq.user.id, pagination, { frequency });
      sendPaginated(res, data, buildPaginationMeta(total, pagination.page, pagination.limit));
    } catch (error) { next(error); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      const income = await incomesService.getById(id, authReq.user.id);
      sendSuccess(res, income);
    } catch (error) { next(error); }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const income = await incomesService.create(authReq.user.id, req.body);
      sendCreated(res, income);
    } catch (error) { next(error); }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      const income = await incomesService.update(id, authReq.user.id, req.body);
      sendSuccess(res, income, 'Income updated successfully');
    } catch (error) { next(error); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await incomesService.delete(id, authReq.user.id);
      sendSuccess(res, null, 'Income deleted successfully');
    } catch (error) { next(error); }
  }
}

export const incomesController = new IncomesController();
