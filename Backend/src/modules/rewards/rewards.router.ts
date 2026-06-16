import { Router } from 'express';
import { rewardsController } from './rewards.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => rewardsController.getSummary(req, res, next));
router.get('/history', (req, res, next) => rewardsController.getHistory(req, res, next));

export default router;
