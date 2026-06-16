import rateLimit from 'express-rate-limit';
import { RATE_LIMIT } from '@shared/constants/index.js';
import { sendError } from '@shared/utils/response.js';

export const generalLimiter = rateLimit({
  windowMs: RATE_LIMIT.GENERAL.windowMs,
  max: RATE_LIMIT.GENERAL.max,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => {
    sendError(res, 'Too many requests, please try again later', 429);
  },
});

export const authLimiter = rateLimit({
  windowMs: RATE_LIMIT.AUTH.windowMs,
  max: RATE_LIMIT.AUTH.max,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => {
    sendError(res, 'Too many authentication attempts, please try again later', 429);
  },
});

export const mlLimiter = rateLimit({
  windowMs: RATE_LIMIT.ML.windowMs,
  max: RATE_LIMIT.ML.max,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => {
    sendError(res, 'Too many ML requests, please try again later', 429);
  },
});

export const writeLimiter = rateLimit({
  windowMs: RATE_LIMIT.WRITE.windowMs,
  max: RATE_LIMIT.WRITE.max,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => {
    sendError(res, 'Too many write operations, please try again later', 429);
  },
});
