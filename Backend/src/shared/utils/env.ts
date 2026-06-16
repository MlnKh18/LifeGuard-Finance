import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),

  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  DIRECT_URL: z.string().min(1, 'DIRECT_URL is required'),

  FIREBASE_PROJECT_ID: z.string().min(1, 'FIREBASE_PROJECT_ID is required'),
  FIREBASE_CLIENT_EMAIL: z.string().default('dummy@example.com'),
  FIREBASE_PRIVATE_KEY: z.string().default('dummy-private-key'),

  ML_SERVICE_URL: z.string().url().default('http://localhost:8000'),

  CORS_ORIGIN: z.string().default('*'),

  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(900000),
  RATE_LIMIT_MAX: z.coerce.number().default(100),

  UPSTASH_REDIS_REST_URL: z.string().optional(),
  UPSTASH_REDIS_REST_TOKEN: z.string().optional(),
});

export type Env = z.infer<typeof envSchema>;

function validateEnv(): Env {
  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    const formatted = result.error.format();
    console.error('❌ Invalid environment variables:');
    console.error(JSON.stringify(formatted, null, 2));
    throw new Error('Invalid environment variables. Check server logs for details.');
  }

  return result.data;
}

export const env = validateEnv();
