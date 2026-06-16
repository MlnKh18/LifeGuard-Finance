import type { Request, Response, NextFunction } from 'express';
import type { Role } from '@prisma/client';
import { AppError } from '@shared/utils/app-error.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';

export function authorize(...allowedRoles: Role[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const authReq = req as AuthenticatedRequest;

    if (!authReq.user) {
      next(AppError.unauthorized('Authentication required'));
      return;
    }

    if (allowedRoles.length === 0) {
      next();
      return;
    }

    const hasRole = authReq.user.roles.some((role) => allowedRoles.includes(role));

    if (!hasRole) {
      next(AppError.forbidden('Insufficient permissions'));
      return;
    }

    next();
  };
}
