import { Router } from 'express';
import { dependentsController } from './dependents.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createDependentSchema, updateDependentSchema } from './dependents.schema.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => dependentsController.list(req, res, next));
router.get('/:id', (req, res, next) => dependentsController.getById(req, res, next));
router.post('/', validate({ body: createDependentSchema }), (req, res, next) => dependentsController.create(req, res, next));
router.patch('/:id', validate({ body: updateDependentSchema }), (req, res, next) => dependentsController.update(req, res, next));
router.delete('/:id', (req, res, next) => dependentsController.delete(req, res, next));

export default router;
