import { Router } from 'express';
import { fvsController } from './fvs.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { mlLimiter } from '@shared/middleware/rate-limiter.js';

const router: Router = Router();
router.use(authenticate);

router.post('/calculate', mlLimiter, (req, res, next) => fvsController.calculate(req, res, next));
router.get('/history', (req, res, next) => fvsController.getHistory(req, res, next));
router.get('/latest', (req, res, next) => fvsController.getLatest(req, res, next));
router.get('/:id', (req, res, next) => fvsController.getById(req, res, next));

export default router;
