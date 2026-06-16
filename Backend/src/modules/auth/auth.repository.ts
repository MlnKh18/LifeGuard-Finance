import { prisma } from '@shared/prisma/client.js';
import type { SyncUserInput } from './auth.schema.js';

export class AuthRepository {
  async findByFirebaseUid(firebaseUid: string) {
    return prisma.user.findUnique({
      where: { firebaseUid },
      include: { roles: true },
    });
  }

  async upsertUser(data: SyncUserInput) {
    return prisma.user.upsert({
      where: { firebaseUid: data.firebaseUid },
      update: {
        email: data.email,
        displayName: data.displayName ?? undefined,
        avatarUrl: data.avatarUrl ?? undefined,
        phoneNumber: data.phoneNumber ?? undefined,
        lastLoginAt: new Date(),
      },
      create: {
        firebaseUid: data.firebaseUid,
        email: data.email,
        displayName: data.displayName ?? null,
        avatarUrl: data.avatarUrl ?? null,
        phoneNumber: data.phoneNumber ?? null,
        lastLoginAt: new Date(),
        roles: {
          create: { role: 'USER' },
        },
      },
      include: { roles: true },
    });
  }
}

export const authRepository = new AuthRepository();
