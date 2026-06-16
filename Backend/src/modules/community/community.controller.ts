import type { Request, Response, NextFunction } from 'express';
import { communityService } from './community.service.js';
import type { AuthenticatedRequest } from '@shared/types/index.js';
import { sendSuccess, sendCreated, sendPaginated } from '@shared/utils/response.js';
import { parsePagination, buildPaginationMeta } from '@shared/utils/pagination.js';

export class CommunityController {
  async listPosts(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const category = typeof req.query.category === 'string' ? req.query.category : undefined;
      const { data, total } = await communityService.listPosts(p, { category });
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async getPostById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await communityService.getPostById(id));
    } catch (e) { next(e); }
  }

  async createPost(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await communityService.createPost((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async updatePost(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await communityService.updatePost(id, (req as AuthenticatedRequest).user.id, req.body), 'Post updated successfully');
    } catch (e) { next(e); }
  }

  async deletePost(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await communityService.deletePost(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Post deleted successfully');
    } catch (e) { next(e); }
  }

  async listComments(req: Request, res: Response, next: NextFunction) {
    try {
      const p = parsePagination(req.query as Record<string, unknown>);
      const postId = req.params.postId;
      if (typeof postId !== 'string') throw new Error('Invalid Post ID');
      const { data, total } = await communityService.listComments(postId, p);
      sendPaginated(res, data, buildPaginationMeta(total, p.page, p.limit));
    } catch (e) { next(e); }
  }

  async createComment(req: Request, res: Response, next: NextFunction) {
    try {
      sendCreated(res, await communityService.createComment((req as AuthenticatedRequest).user.id, req.body));
    } catch (e) { next(e); }
  }

  async updateComment(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      sendSuccess(res, await communityService.updateComment(id, (req as AuthenticatedRequest).user.id, req.body), 'Comment updated successfully');
    } catch (e) { next(e); }
  }

  async deleteComment(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;
      if (typeof id !== 'string') throw new Error('Invalid ID');
      await communityService.deleteComment(id, (req as AuthenticatedRequest).user.id);
      sendSuccess(res, null, 'Comment deleted successfully');
    } catch (e) { next(e); }
  }
}

export const communityController = new CommunityController();
