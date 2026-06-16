import { Router } from 'express';
import { literacyController } from './literacy.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => literacyController.list(req, res, next));
router.get('/:id', (req, res, next) => literacyController.getById(req, res, next));

export default router;
