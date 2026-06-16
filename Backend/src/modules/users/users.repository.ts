import { prisma } from '@shared/prisma/client.js';
import type { UpdateUserInput } from './users.schema.js';

export class UsersRepository {
  async findById(id: string) {
    return prisma.user.findUnique({
      where: { id },
      include: { roles: true },
    });
  }

  async update(id: string, data: UpdateUserInput) {
    return prisma.user.update({
      where: { id },
      data,
      include: { roles: true },
    });
  }
}

export const usersRepository = new UsersRepository();
