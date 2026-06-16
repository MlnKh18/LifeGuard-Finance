import { profilesRepository } from './profiles.repository.js';
import { AppError } from '@shared/utils/app-error.js';
import type { CreateProfileInput, UpdateProfileInput } from './profiles.schema.js';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class ProfilesService {
  async list(userId: string, pagination: PaginationParams) {
    return profilesRepository.findMany(userId, pagination);
  }

  async getById(id: string, userId: string) {
    const profile = await profilesRepository.findById(id);
    if (!profile || profile.userId !== userId) throw AppError.notFound('Profile not found');
    return profile;
  }

  async create(userId: string, data: CreateProfileInput) {
    return profilesRepository.create(userId, data);
  }

  async update(id: string, userId: string, data: UpdateProfileInput) {
    await this.getById(id, userId);
    return profilesRepository.update(id, data);
  }

  async delete(id: string, userId: string) {
    await this.getById(id, userId);
    return profilesRepository.softDelete(id);
  }
}

export const profilesService = new ProfilesService();
