import { Router } from 'express';
import { expensesController } from './expenses.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createExpenseSchema, updateExpenseSchema } from './expenses.schema.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => expensesController.list(req, res, next));
router.get('/:id', (req, res, next) => expensesController.getById(req, res, next));
router.post('/', validate({ body: createExpenseSchema }), (req, res, next) => expensesController.create(req, res, next));
router.patch('/:id', validate({ body: updateExpenseSchema }), (req, res, next) => expensesController.update(req, res, next));
router.delete('/:id', (req, res, next) => expensesController.delete(req, res, next));

export default router;
