import { z } from 'zod';
import { Role } from '@prisma/client';

export const syncUserSchema = z.object({
  firebaseUid: z.string().min(1),
  email: z.string().email(),
  displayName: z.string().nullable().optional(),
  avatarUrl: z.string().url().nullable().optional(),
  phoneNumber: z.string().nullable().optional(),
  role: z.nativeEnum(Role),
  familyCode: z.string().nullable().optional(),
  inviteCode: z.string().nullable().optional(),
});

export type SyncUserInput = z.infer<typeof syncUserSchema>;
