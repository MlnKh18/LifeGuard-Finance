import { z } from 'zod';

export const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(5000),
  category: z.string().max(50).optional(),
});

export const updatePostSchema = createPostSchema.partial();

export const createCommentSchema = z.object({
  postId: z.string().uuid(),
  content: z.string().min(1).max(2000),
});

export const updateCommentSchema = z.object({
  content: z.string().min(1).max(2000),
});

export type CreatePostInput = z.infer<typeof createPostSchema>;
export type UpdatePostInput = z.infer<typeof updatePostSchema>;
export type CreateCommentInput = z.infer<typeof createCommentSchema>;
export type UpdateCommentInput = z.infer<typeof updateCommentSchema>;
