import type { Response } from 'express';
import type { PaginationMeta } from '@shared/types/index.js';

export function sendSuccess<T>(
  res: Response,
  data: T,
  message: string = 'Success',
  statusCode: number = 200,
  meta?: Record<string, unknown>,
): void {
  const response = {
    success: true as const,
    message,
    data,
    ...(meta && { meta }),
  };
  res.status(statusCode).json(response);
}

export function sendError(
  res: Response,
  message: string,
  statusCode: number = 500,
  errors: unknown[] = [],
): void {
  const response = {
    success: false as const,
    message,
    errors,
  };
  res.status(statusCode).json(response);
}

export function sendPaginated<T>(
  res: Response,
  data: T[],
  pagination: PaginationMeta,
  message: string = 'Success',
): void {
  sendSuccess(res, data, message, 200, { pagination });
}

export function sendCreated<T>(
  res: Response,
  data: T,
  message: string = 'Created successfully',
): void {
  sendSuccess(res, data, message, 201);
}

export function sendNoContent(res: Response): void {
  res.status(204).send();
}
