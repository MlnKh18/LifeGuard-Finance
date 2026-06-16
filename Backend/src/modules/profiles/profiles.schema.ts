import { z } from 'zod';

export const createProfileSchema = z.object({
  name: z.string().min(1).max(100),
  relationship: z.string().min(1).max(50),
  dateOfBirth: z.string().datetime().optional(),
  notes: z.string().max(500).optional(),
});

export const updateProfileSchema = createProfileSchema.partial();

export type CreateProfileInput = z.infer<typeof createProfileSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
