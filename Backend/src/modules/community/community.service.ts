import { prisma } from '@shared/prisma/client.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreatePostInput, UpdatePostInput, CreateCommentInput, UpdateCommentInput } from './community.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class CommunityService {
  async listPosts(pagination: PaginationParams, filters?: { category?: string }) {
    const where: any = {};
    if (filters?.category) where.category = filters.category;
    const [data, total] = await Promise.all([
      prisma.communityPost.findMany({
        where, skip: pagination.skip, take: pagination.take, orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
        include: { user: { select: { id: true, displayName: true, avatarUrl: true } }, _count: { select: { comments: true } } },
      }),
      prisma.communityPost.count({ where }),
    ]);
    return { data, total };
  }

  async getPostById(id: string) {
    const post = await prisma.communityPost.findUnique({
      where: { id },
      include: { user: { select: { id: true, displayName: true, avatarUrl: true } }, comments: { where: { deletedAt: null }, include: { user: { select: { id: true, displayName: true, avatarUrl: true } } }, orderBy: { createdAt: 'asc' } } },
    });
    if (!post) throw AppError.notFound('Post not found');
    return post;
  }

  async createPost(userId: string, data: CreatePostInput) {
    return prisma.communityPost.create({
      data: { userId, ...data },
      include: { user: { select: { id: true, displayName: true, avatarUrl: true } } },
    });
  }

  async updatePost(id: string, userId: string, data: UpdatePostInput) {
    const post = await prisma.communityPost.findUnique({ where: { id } });
    if (!post || post.userId !== userId) throw AppError.forbidden('You can only edit your own posts');
    return prisma.communityPost.update({ where: { id }, data });
  }

  async deletePost(id: string, userId: string) {
    const post = await prisma.communityPost.findUnique({ where: { id } });
    if (!post || post.userId !== userId) throw AppError.forbidden('You can only delete your own posts');
    return prisma.communityPost.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  async listComments(postId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.communityComment.findMany({
        where: { postId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'asc' },
        include: { user: { select: { id: true, displayName: true, avatarUrl: true } } },
      }),
      prisma.communityComment.count({ where: { postId } }),
    ]);
    return { data, total };
  }

  async createComment(userId: string, data: CreateCommentInput) {
    const post = await prisma.communityPost.findUnique({ where: { id: data.postId } });
    if (!post) throw AppError.notFound('Post not found');
    return prisma.communityComment.create({
      data: { userId, postId: data.postId, content: data.content },
      include: { user: { select: { id: true, displayName: true, avatarUrl: true } } },
    });
  }

  async updateComment(id: string, userId: string, data: UpdateCommentInput) {
    const comment = await prisma.communityComment.findUnique({ where: { id } });
    if (!comment || comment.userId !== userId) throw AppError.forbidden('You can only edit your own comments');
    return prisma.communityComment.update({ where: { id }, data });
  }

  async deleteComment(id: string, userId: string) {
    const comment = await prisma.communityComment.findUnique({ where: { id } });
    if (!comment || comment.userId !== userId) throw AppError.forbidden('You can only delete your own comments');
    return prisma.communityComment.update({ where: { id }, data: { deletedAt: new Date() } });
  }
}

export const communityService = new CommunityService();
