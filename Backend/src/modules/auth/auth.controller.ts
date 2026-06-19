import type { Request, Response, NextFunction } from 'express';
import { authService } from './auth.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated } from '@shared/utils/response.js';
import { syncUserSchema } from './auth.schema.js';

export class AuthController {
  async getMe(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const user = await authService.getMe(authReq.user.firebaseUid);
      sendSuccess(res, user, 'User retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async syncUser(req: Request, res: Response, next: NextFunction) {
    try {
      const firebaseUser = (req as any).firebaseUser;
      
      const bodyToValidate = {
        ...req.body,
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email,
      };

      if (!bodyToValidate.displayName && firebaseUser.name) {
        bodyToValidate.displayName = firebaseUser.name;
      }

      const validatedBody = syncUserSchema.parse(bodyToValidate);

      const user = await authService.syncUser(validatedBody);
      sendCreated(res, user, 'User synced successfully');
    } catch (error) {
      next(error);
    }
  }
}

export const authController = new AuthController();
