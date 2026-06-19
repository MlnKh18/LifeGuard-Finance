import { Router } from 'express';
import { authController } from './auth.controller.js';
import { authenticate, verifyFirebaseToken } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { syncUserSchema } from './auth.schema.js';
import { authLimiter } from '@shared/middleware/rate-limiter.js';

const router: Router = Router();

router.get('/me', authLimiter, authenticate, (req, res, next) => authController.getMe(req, res, next));

router.post(
  '/sync-user',
  authLimiter,
  verifyFirebaseToken,
  (req, res, next) => authController.syncUser(req, res, next),
);

export default router;
