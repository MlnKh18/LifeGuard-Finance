import { Router } from 'express';
import { notificationsController } from './notifications.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => notificationsController.list(req, res, next));
router.patch('/:id/read', (req, res, next) => notificationsController.markAsRead(req, res, next));
router.patch('/read-all', (req, res, next) => notificationsController.markAllAsRead(req, res, next));

export default router;
