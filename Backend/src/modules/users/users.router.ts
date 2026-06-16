import { Router } from 'express';
import { usersController } from './users.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { updateUserSchema } from './users.schema.js';

const router: Router = Router();

router.get('/me', authenticate, (req, res, next) => usersController.getMe(req, res, next));

router.patch(
  '/me',
  authenticate,
  validate({ body: updateUserSchema }),
  (req, res, next) => usersController.updateMe(req, res, next),
);

export default router;
