import { usersRepository } from './users.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { UpdateUserInput } from './users.schema.js';

export class UsersService {
  async getMe(userId: string) {
    const user = await usersRepository.findById(userId);
    if (!user) throw AppError.notFound('User not found');

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
      updatedAt: user.updatedAt,
    };
  }

  async updateMe(userId: string, data: UpdateUserInput) {
    const user = await usersRepository.update(userId, data);

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
      updatedAt: user.updatedAt,
    };
  }
}

export const usersService = new UsersService();
