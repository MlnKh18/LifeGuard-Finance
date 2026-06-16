import type { Request, Response, NextFunction } from 'express';
import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';

interface OwnershipConfig {
  model: string;
  paramName?: string;
  userField?: string;
}

export function ownershipGuard(config: OwnershipConfig) {
  const { model, paramName = 'id', userField = 'userId' } = config;

  return async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
    try {
      const authReq = req as AuthenticatedRequest;
      const resourceId = req.params[paramName];

      if (!resourceId) {
        next(AppError.badRequest(`Missing parameter: ${paramName}`));
        return;
      }

      const prismaModel = (prisma as Record<string, any>)[
        model.charAt(0).toLowerCase() + model.slice(1)
      ];

      if (!prismaModel) {
        next(AppError.internal(`Invalid model: ${model}`));
        return;
      }

      const resource = await prismaModel.findFirst({
        where: { id: resourceId },
        select: { [userField]: true },
      });

      if (!resource) {
        next(AppError.notFound('Resource not found'));
        return;
      }

      const isAdmin = authReq.user.roles.includes('ADMIN' as any);

      if (resource[userField] !== authReq.user.id && !isAdmin) {
        next(AppError.forbidden('You do not own this resource'));
        return;
      }

      next();
    } catch (error) {
      next(error);
    }
  };
}
