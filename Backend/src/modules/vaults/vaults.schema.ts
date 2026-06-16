import { z } from 'zod';

export const createVaultSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  targetAmount: z.number().positive(),
  currentAmount: z.number().nonnegative().default(0),
  currency: z.string().length(3).default('IDR'),
  deadline: z.string().datetime().optional(),
  iconUrl: z.string().url().optional(),
  color: z.string().max(20).optional(),
});

export const updateVaultSchema = createVaultSchema.partial();
export type CreateVaultInput = z.infer<typeof createVaultSchema>;
export type UpdateVaultInput = z.infer<typeof updateVaultSchema>;
