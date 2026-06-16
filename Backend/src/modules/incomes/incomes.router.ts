import { Router } from 'express';
import { incomesController } from './incomes.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createIncomeSchema, updateIncomeSchema } from './incomes.schema.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => incomesController.list(req, res, next));
router.get('/:id', (req, res, next) => incomesController.getById(req, res, next));
router.post('/', validate({ body: createIncomeSchema }), (req, res, next) => incomesController.create(req, res, next));
router.patch('/:id', validate({ body: updateIncomeSchema }), (req, res, next) => incomesController.update(req, res, next));
router.delete('/:id', (req, res, next) => incomesController.delete(req, res, next));

export default router;
