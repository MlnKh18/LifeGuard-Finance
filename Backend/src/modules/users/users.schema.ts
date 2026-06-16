import { z } from 'zod';

export const updateUserSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  avatarUrl: z.string().url().nullable().optional(),
  phoneNumber: z.string().max(20).nullable().optional(),
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
