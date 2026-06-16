import { z } from 'zod';

const protectionTypeEnum = z.enum(['LIFE_INSURANCE', 'HEALTH_INSURANCE', 'VEHICLE_INSURANCE', 'PROPERTY_INSURANCE', 'TRAVEL_INSURANCE', 'EDUCATION_INSURANCE', 'EMERGENCY_FUND', 'OTHER']);
const frequencyEnum = z.enum(['DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'SEMI_ANNUALLY', 'ANNUALLY', 'ONE_TIME']);

export const createProtectionSchema = z.object({
  type: protectionTypeEnum,
  provider: z.string().min(1).max(100),
  policyNumber: z.string().max(50).optional(),
  coverageAmount: z.number().positive(),
  premium: z.number().nonnegative(),
  premiumFrequency: frequencyEnum.default('MONTHLY'),
  currency: z.string().length(3).default('IDR'),
  startDate: z.string().datetime().optional(),
  expiryDate: z.string().datetime().optional(),
  isActive: z.boolean().default(true),
  notes: z.string().max(500).optional(),
});

export const updateProtectionSchema = createProtectionSchema.partial();
export type CreateProtectionInput = z.infer<typeof createProtectionSchema>;
export type UpdateProtectionInput = z.infer<typeof updateProtectionSchema>;
