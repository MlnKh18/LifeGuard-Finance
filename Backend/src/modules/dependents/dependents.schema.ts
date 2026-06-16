import { z } from 'zod';

export const createDependentSchema = z.object({
  name: z.string().min(1).max(100),
  relationship: z.string().min(1).max(50),
  dateOfBirth: z.string().datetime().optional(),
  needsEducation: z.boolean().default(false),
  monthlyCost: z.number().nonnegative().nullable().optional(),
  notes: z.string().max(500).optional(),
});

export const updateDependentSchema = createDependentSchema.partial();
export type CreateDependentInput = z.infer<typeof createDependentSchema>;
export type UpdateDependentInput = z.infer<typeof updateDependentSchema>;
