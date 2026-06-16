import { authRepository } from './auth.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { SyncUserInput } from './auth.schema.js';

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
      isActive: user.isActive,
      roles: user.roles.map((r) => r.role),
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
    };
  }

  async syncUser(data: SyncUserInput) {
    const user = await authRepository.upsertUser(data);

    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      phoneNumber: user.phoneNumber,
      isActive: user.isActive,
      roles: user.roles.map((r) => r.role),
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
    };
  }
}

export const authService = new AuthService();
