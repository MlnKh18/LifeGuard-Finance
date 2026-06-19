import { z } from 'zod';
import { VaultScope, VaultPriority, SavingFrequency } from '@prisma/client';

export const createVaultSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  targetAmount: z.number().positive(),
  periodicTargetAmount: z.number().positive().optional(),
  currentAmount: z.number().nonnegative().default(0),
  currency: z.string().length(3).default('IDR'),
  deadline: z.string().datetime().optional(),
  iconName: z.string().optional(),
  color: z.string().max(20).optional(),
  scope: z.nativeEnum(VaultScope).default('PERSONAL'),
  priority: z.nativeEnum(VaultPriority).default('MEDIUM'),
  savingFrequency: z.nativeEnum(SavingFrequency).default('MONTHLY'),
  ownerEmail: z.string().email().optional(),
});

export const updateVaultSchema = createVaultSchema.partial();
export type CreateVaultInput = z.infer<typeof createVaultSchema>;
export type UpdateVaultInput = z.infer<typeof updateVaultSchema>;
