import { Router } from 'express';
import { protectionsController } from './protections.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createProtectionSchema, updateProtectionSchema } from './protections.schema.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => protectionsController.list(req, res, next));
router.get('/:id', (req, res, next) => protectionsController.getById(req, res, next));
router.post('/', validate({ body: createProtectionSchema }), (req, res, next) => protectionsController.create(req, res, next));
router.patch('/:id', validate({ body: updateProtectionSchema }), (req, res, next) => protectionsController.update(req, res, next));
router.delete('/:id', (req, res, next) => protectionsController.delete(req, res, next));

export default router;
