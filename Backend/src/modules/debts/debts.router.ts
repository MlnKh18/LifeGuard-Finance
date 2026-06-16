import { Router } from 'express';
import { debtsController } from './debts.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createDebtSchema, updateDebtSchema } from './debts.schema.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => debtsController.list(req, res, next));
router.get('/:id', (req, res, next) => debtsController.getById(req, res, next));
router.post('/', validate({ body: createDebtSchema }), (req, res, next) => debtsController.create(req, res, next));
router.patch('/:id', validate({ body: updateDebtSchema }), (req, res, next) => debtsController.update(req, res, next));
router.delete('/:id', (req, res, next) => debtsController.delete(req, res, next));

export default router;
