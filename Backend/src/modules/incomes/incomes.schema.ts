import { z } from 'zod';

const incomeFrequencyEnum = z.enum(['DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'SEMI_ANNUALLY', 'ANNUALLY', 'ONE_TIME']);

export const createIncomeSchema = z.object({
  source: z.string().min(1).max(100),
  amount: z.number().positive(),
  currency: z.string().length(3).default('IDR'),
  frequency: incomeFrequencyEnum,
  description: z.string().max(500).optional(),
  isActive: z.boolean().default(true),
  startDate: z.string().datetime().optional(),
  endDate: z.string().datetime().optional(),
});

export const updateIncomeSchema = createIncomeSchema.partial();

export type CreateIncomeInput = z.infer<typeof createIncomeSchema>;
export type UpdateIncomeInput = z.infer<typeof updateIncomeSchema>;
