import { Router } from 'express';
import { anomaliesController } from './anomalies.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { mlLimiter } from '@shared/middleware/rate-limiter.js';

const router: Router = Router();
router.use(authenticate);

router.post('/detect', mlLimiter, (req, res, next) => anomaliesController.detect(req, res, next));
router.get('/', (req, res, next) => anomaliesController.list(req, res, next));
router.get('/:id', (req, res, next) => anomaliesController.getById(req, res, next));

export default router;
