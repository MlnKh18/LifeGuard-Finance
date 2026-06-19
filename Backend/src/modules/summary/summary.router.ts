import { Router } from 'express';
import { summaryController } from './summary.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';

const router: Router = Router();

router.get('/profile-summary/me', authenticate, (req, res, next) => summaryController.getProfileSummary(req, res, next));
router.get('/dashboard-summary', authenticate, (req, res, next) => summaryController.getDashboardSummary(req, res, next));

export default router;
