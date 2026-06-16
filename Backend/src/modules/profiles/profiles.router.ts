import { Router } from 'express';
import { profilesController } from './profiles.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createProfileSchema, updateProfileSchema } from './profiles.schema.js';

const router: Router = Router();

router.use(authenticate);

router.get('/', (req, res, next) => profilesController.list(req, res, next));
router.get('/:id', (req, res, next) => profilesController.getById(req, res, next));
router.post('/', validate({ body: createProfileSchema }), (req, res, next) => profilesController.create(req, res, next));
router.patch('/:id', validate({ body: updateProfileSchema }), (req, res, next) => profilesController.update(req, res, next));
router.delete('/:id', (req, res, next) => profilesController.delete(req, res, next));

export default router;
