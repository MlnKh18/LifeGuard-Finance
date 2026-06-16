import type { Request, Response, NextFunction } from 'express';
import { vaultsService } from './vaults.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class VaultsController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await vaultsService.list((req as AuthenticatedRequest).user.id, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await vaultsService.getById(id, (req as AuthenticatedRequest).user.id));
    } catch (e) { next(e); }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await vaultsService.create((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await vaultsService.update(id, (req as AuthenticatedRequest).user.id, req.body), 'Vault updated successfully');
    } catch (e) { next(e); }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await vaultsService.delete(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Vault deleted successfully');
    } catch (e) { next(e); }
  }
}

export const vaultsController = new VaultsController();
