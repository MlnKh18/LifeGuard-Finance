import type { Request, Response, NextFunction } from 'express';
import { summaryService } from './summary.service.js';
import { sendSuccess } from '@shared/utils/response.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';

export class SummaryController {
  async getProfileSummary(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const data = await summaryService.getProfileSummary(authReq.user.id);
      sendSuccess(res, data, 'Profile summary retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDashboardSummary(req: Request, res: Response, next: NextFunction) {
    try {
      const authReq = req as AuthenticatedRequest;
      const data = await summaryService.getDashboardSummary(authReq.user.id);
      sendSuccess(res, data, 'Dashboard summary retrieved successfully');
    } catch (error) {
      next(error);
    }
  }
}

export const summaryController = new SummaryController();
