import type { Request, Response, NextFunction } from 'express';
import { profilesService } from './profiles.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class ProfilesController {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const pagination = parsePagination(req.query as Record<string, unknown>);
      const { data, total } = await profilesService.list(authReq.user.id, pagination);
      const meta = buildPaginationMeta(total, pagination.page, pagination.limit);
      sendPaginated(res, data, meta);
    } catch (error) {
      next(error);
    }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      const profile = await profilesService.getById(id, authReq.user.id);
      sendSuccess(res, profile);
    } catch (error) {
      next(error);
    }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const profile = await profilesService.create(authReq.user.id, req.body);
      sendCreated(res, profile);
    } catch (error) {
      next(error);
    }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      const profile = await profilesService.update(id, authReq.user.id, req.body);
      sendSuccess(res, profile, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await profilesService.delete(id, authReq.user.id);
      sendSuccess(res, null, 'Profile deleted successfully');
    } catch (error) {
      next(error);
    }
  }
}

export const profilesController = new ProfilesController();
