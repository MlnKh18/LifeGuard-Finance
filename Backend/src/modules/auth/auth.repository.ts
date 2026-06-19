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
    return prisma.$transaction(async (tx) => {
      let user = await tx.user.findUnique({
        where: { firebaseUid: data.firebaseUid },
        include: { roles: true },
      });

      if (user) {
        user = await tx.user.update({
          where: { firebaseUid: data.firebaseUid },
          data: {
            email: data.email,
            displayName: data.displayName ?? undefined,
            avatarUrl: data.avatarUrl ?? undefined,
            phoneNumber: data.phoneNumber ?? undefined,
            familyCode: data.familyCode ?? undefined,
            lastLoginAt: new Date(),
          },
          include: { roles: true },
        });

        const hasRole = user.roles.some((r) => r.role === data.role);
        if (!hasRole) {
          await tx.userRole.deleteMany({
            where: { userId: user.id },
          });

          await tx.userRole.create({
            data: {
              userId: user.id,
              role: data.role,
            },
          });
          user.roles = await tx.userRole.findMany({ where: { userId: user.id } });
        }
      } else {
        user = await tx.user.create({
          data: {
            firebaseUid: data.firebaseUid,
            email: data.email,
            displayName: data.displayName ?? null,
            avatarUrl: data.avatarUrl ?? null,
            phoneNumber: data.phoneNumber ?? null,
            familyCode: data.familyCode ?? null,
            lastLoginAt: new Date(),
            roles: {
              create: { role: data.role },
            },
          },
          include: { roles: true },
        });
      }

      return user;
    });
  }
}

export const authRepository = new AuthRepository();
