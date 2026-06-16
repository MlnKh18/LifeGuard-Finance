import { Router } from 'express';
import { recommendationsController } from './recommendations.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => recommendationsController.list(req, res, next));
router.get('/:id', (req, res, next) => recommendationsController.getById(req, res, next));

export default router;
