import type { Request, Response, NextFunction } from 'express';
import { rewardsService } from './rewards.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class RewardsController {
  async getSummary(req: Request, res: Response, next: NextFunction) { try { sendSuccess(res, await rewardsService.getSummary((req as AuthenticatedRequest).user.id)); } catch (e) { next(e); } }
  async getHistory(req: Request, res: Response, next: NextFunction) { try { const p = parsePagination(req.query as Record<string, unknown>); const { data, total } = await rewardsService.getHistory((req as AuthenticatedRequest).user.id, p); sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit)); } catch (e) { next(e); } }
}

export const rewardsController = new RewardsController();
