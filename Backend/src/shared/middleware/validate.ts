import type { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';
import { AppError } from '@shared/utils/app-error.js';

interface ValidationTarget {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

export function validate(schemas: ValidationTarget) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const errors: unknown[] = [];

    if (schemas.body) {
      const result = schemas.body.safeParse(req.body);
      if (!result.success) {
        errors.push(
          ...result.error.errors.map((e) => ({
            field: `body.${e.path.join('.')}`,
            message: e.message,
          })),
        );
      } else {
        req.body = result.data;
      }
    }

    if (schemas.query) {
      const result = schemas.query.safeParse(req.query);
      if (!result.success) {
        errors.push(
          ...result.error.errors.map((e) => ({
            field: `query.${e.path.join('.')}`,
            message: e.message,
          })),
        );
      } else {
        (req as any).validatedQuery = result.data;
      }
    }

    if (schemas.params) {
      const result = schemas.params.safeParse(req.params);
      if (!result.success) {
        errors.push(
          ...result.error.errors.map((e) => ({
            field: `params.${e.path.join('.')}`,
            message: e.message,
          })),
        );
      }
    }

    if (errors.length > 0) {
      next(AppError.badRequest('Validation failed', errors));
      return;
    }

    next();
  };
}
