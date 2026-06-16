import type { Request, Response, NextFunction } from 'express';
import { expensesService } from './expenses.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class ExpensesController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const pagination = parsePagination(req.query as Record<string, unknown>);
      const filters = {
        category: typeof req.query.category === 'string' ? req.query.category : undefined,
        startDate: typeof req.query.startDate === 'string' ? req.query.startDate : undefined,
        endDate: typeof req.query.endDate === 'string' ? req.query.endDate : undefined
      };
      const { data, total } = await expensesService.list(authReq.user.id, pagination, filters);
      sendPaginated(res, data, buildPaginationMeta(total, pagination.page, pagination.limit));
    } catch (error) { next(error); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await expensesService.getById(id, authReq.user.id));
    } catch (error) { next(error); }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      sendCreated(res, await expensesService.create(authReq.user.id, req.body));
    } catch (error) { next(error); }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await expensesService.update(id, authReq.user.id, req.body), 'Expense updated successfully');
    } catch (error) { next(error); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await expensesService.delete(id, authReq.user.id);
      sendSuccess(res, null, 'Expense deleted successfully');
    } catch (error) { next(error); }
  }
}

export const expensesController = new ExpensesController();
