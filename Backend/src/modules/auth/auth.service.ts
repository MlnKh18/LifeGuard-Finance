import { authRepository } from './auth.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { SyncUserInput } from './auth.schema.js';
import { prisma } from '@shared/prisma/client.js';
import { Role } from '@prisma/client';

export class AuthService {
  async getMe(firebaseUid: string) {
    const user = await authRepository.findByFirebaseUid(firebaseUid);

    if (!user) {
      throw AppError.notFound('User not found. Please sync your account.');
    }

    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      phoneNumber: user.phoneNumber,
      familyCode: user.familyCode,
      isActive: user.isActive,
      roles: user.roles.map((r) => r.role),
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
    };
  }

  async syncUser(data: SyncUserInput) {
    let finalFamilyCode = data.familyCode;

    if (data.role === Role.HEAD_OF_FAMILY) {
      if (!finalFamilyCode) {
        const randomStr = Math.random().toString(36).substring(2, 8).toUpperCase();
        finalFamilyCode = `LGF-${randomStr}`;
      }
    } else if (data.role === Role.FAMILY_MEMBER) {
      if (!finalFamilyCode || !data.inviteCode) {
        throw AppError.badRequest('Family code and invite code are required for family members');
      }

      const invitation = await prisma.familyInvitation.findUnique({
        where: { inviteCode: data.inviteCode },
      });

      if (!invitation) {
        throw AppError.badRequest('Invalid invitation code');
      }

      if (invitation.familyCode !== finalFamilyCode) {
        throw AppError.badRequest('Family code does not match invitation');
      }

      if (invitation.status !== 'PENDING') {
        throw AppError.badRequest(`Invitation is already ${invitation.status.toLowerCase()}`);
      }

      await prisma.familyInvitation.update({
        where: { id: invitation.id },
        data: { status: 'ACCEPTED' },
      });
    }

    const user = await authRepository.upsertUser({
      ...data,
      familyCode: finalFamilyCode,
    });

    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      phoneNumber: user.phoneNumber,
      familyCode: user.familyCode,
      isActive: user.isActive,
      roles: user.roles.map((r) => r.role),
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
    };
  }
}

export const authService = new AuthService();
