import { Router } from 'express';
import { vaultsController } from './vaults.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { validate } from '@shared/middleware/validate.js';
import { createVaultSchema, updateVaultSchema } from './vaults.schema.js';

const router: Router = Router();
router.use(authenticate);

router.get('/', (req, res, next) => vaultsController.list(req, res, next));
router.get('/:id', (req, res, next) => vaultsController.getById(req, res, next));
router.post('/', validate({ body: createVaultSchema }), (req, res, next) => vaultsController.create(req, res, next));
router.patch('/:id', validate({ body: updateVaultSchema }), (req, res, next) => vaultsController.update(req, res, next));
router.delete('/:id', (req, res, next) => vaultsController.delete(req, res, next));

export default router;
