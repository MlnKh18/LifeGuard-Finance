import { z } from 'zod';

const expenseCategoryEnum = z.enum(['FOOD', 'TRANSPORTATION', 'HOUSING', 'UTILITIES', 'HEALTHCARE', 'EDUCATION', 'ENTERTAINMENT', 'SHOPPING', 'INSURANCE', 'SAVINGS', 'DEBT_PAYMENT', 'CHARITY', 'PERSONAL_CARE', 'TRAVEL', 'SUBSCRIPTIONS', 'OTHER']);

export const createExpenseSchema = z.object({
  category: expenseCategoryEnum,
  amount: z.number().positive(),
  currency: z.string().length(3).default('IDR'),
  description: z.string().max(500).optional(),
  date: z.string().datetime().optional(),
  isRecurring: z.boolean().default(false),
});

export const updateExpenseSchema = createExpenseSchema.partial();

export type CreateExpenseInput = z.infer<typeof createExpenseSchema>;
export type UpdateExpenseInput = z.infer<typeof updateExpenseSchema>;
