import { Router } from 'express';
import { simulationsController } from './simulations.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createSimulationSchema } from './simulations.schema.js';
import { mlLimiter } from '@shared/middleware/rate-limiter.js';

const router: Router = Router();
router.use(authenticate);

router.post('/', mlLimiter, validate({ body: createSimulationSchema }), (req, res, next) => simulationsController.create(req, res, next));
router.get('/', (req, res, next) => simulationsController.list(req, res, next));
router.get('/:id', (req, res, next) => simulationsController.getById(req, res, next));
router.delete('/:id', (req, res, next) => simulationsController.delete(req, res, next));

export default router;
