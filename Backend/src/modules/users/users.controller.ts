import type { Request, Response, NextFunction } from 'express';
import { usersService } from './users.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess } from '@shared/utils/response.js';

export class UsersController {
  async getMe(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const user = await usersService.getMe(authReq.user.id);
      sendSuccess(res, user);
    } catch (error) {
      next(error);
    }
  }

  async updateMe(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const user = await usersService.updateMe(authReq.user.id, req.body);
      sendSuccess(res, user, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }
}

export const usersController = new UsersController();
