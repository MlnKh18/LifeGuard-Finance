import type { Request } from 'express';
import type { Role } from '@prisma/client';

export interface AuthUser {
  id: string;
  firebaseUid: string;
  email: string;
  roles: Role[];
}

export interface AuthenticatedRequest extends Request {
  user: AuthUser;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export interface ApiSuccessResponse<T = unknown> {
  success: true;
  message: string;
  data: T;
  meta?: Record<string, unknown>;
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  errors: unknown[];
}

export type ApiResponse<T = unknown> = ApiSuccessResponse<T> | ApiErrorResponse;

export interface ListQuery {
  page?: string;
  limit?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}

export interface DateRangeFilter {
  startDate?: string;
  endDate?: string;
}
