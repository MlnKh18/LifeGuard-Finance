import type { Request, Response, NextFunction } from 'express';
import { verifyIdToken } from '@shared/firebase/admin.js';
import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import type { Role } from '@prisma/client';

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw AppError.unauthorized('Missing or invalid authorization header');
    }

    const token = authHeader.split(' ')[1];

    if (!token) {
      throw AppError.unauthorized('Token not provided');
    }

    const decodedToken = await verifyIdToken(token);

    const user = await prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
      include: { roles: true },
    });

    if (!user) {
      throw AppError.unauthorized('User not found. Please sync your account first.');
    }

    if (!user.isActive) {
      throw AppError.forbidden('Account has been deactivated');
    }

    (req as AuthenticatedRequest).user = {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      roles: user.roles.map((r) => r.role as Role),
    };

    next();
  } catch (error) {
    if (error instanceof AppError) {
      next(error);
      return;
    }
    next(AppError.unauthorized('Invalid or expired token'));
  }
}
