import { z } from 'zod';

export const createDebtSchema = z.object({
  creditor: z.string().min(1).max(100),
  principal: z.number().positive(),
  remainingBalance: z.number().nonnegative(),
  interestRate: z.number().min(0).max(100),
  monthlyPayment: z.number().nonnegative(),
  currency: z.string().length(3).default('IDR'),
  status: z.enum(['ACTIVE', 'PAID_OFF', 'DEFAULTED', 'RESTRUCTURED']).default('ACTIVE'),
  startDate: z.string().datetime().optional(),
  dueDate: z.string().datetime().optional(),
  description: z.string().max(500).optional(),
});

export const updateDebtSchema = createDebtSchema.partial();
export type CreateDebtInput = z.infer<typeof createDebtSchema>;
export type UpdateDebtInput = z.infer<typeof updateDebtSchema>;
