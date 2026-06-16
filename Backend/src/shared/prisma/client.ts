import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

const basePrisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = basePrisma;
}

const softDeleteModels = [
  'user',
  'familyProfile',
  'income',
  'expense',
  'debt',
  'dependent',
  'protection',
  'savingsVault',
  'communityPost',
  'communityComment',
  'simulationResult',
];

export const prisma = basePrisma.$extends({
  query: {
    $allModels: {
      async findMany({ model, args, query }) {
        const modelName = model.charAt(0).toLowerCase() + model.slice(1);
        if (softDeleteModels.includes(modelName)) {
          args.where = { deletedAt: null, ...args.where };
        }
        return query(args);
      },
      async findFirst({ model, args, query }) {
        const modelName = model.charAt(0).toLowerCase() + model.slice(1);
        if (softDeleteModels.includes(modelName)) {
          args.where = { deletedAt: null, ...args.where };
        }
        return query(args);
      },
      async findUnique({ model, args, query }) {
        const modelName = model.charAt(0).toLowerCase() + model.slice(1);
        if (softDeleteModels.includes(modelName)) {
          args.where = { deletedAt: null, ...args.where };
        }
        return query(args);
      },
      async count({ model, args, query }) {
        const modelName = model.charAt(0).toLowerCase() + model.slice(1);
        if (softDeleteModels.includes(modelName)) {
          args.where = { deletedAt: null, ...args.where };
        }
        return query(args);
      },
    },
  },
}) as unknown as PrismaClient;

export default prisma;
