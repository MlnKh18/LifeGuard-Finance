import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import swaggerUi from 'swagger-ui-express';
import { env } from '@shared/utils/env.js';
import { generalLimiter } from '@shared/middleware/rate-limiter.js';
import { errorHandler } from '@shared/middleware/error-handler.js';
import { sendError } from '@shared/utils/response.js';
import { API_PREFIX } from '@shared/constants/index.js';
import { swaggerSpec } from '@shared/swagger/config.js';

import authRouter from '@modules/auth/auth.router.js';
import usersRouter from '@modules/users/users.router.js';
import profilesRouter from '@modules/profiles/profiles.router.js';
import incomesRouter from '@modules/incomes/incomes.router.js';
import expensesRouter from '@modules/expenses/expenses.router.js';
import debtsRouter from '@modules/debts/debts.router.js';
import dependentsRouter from '@modules/dependents/dependents.router.js';
import protectionsRouter from '@modules/protections/protections.router.js';
import fvsRouter from '@modules/fvs/fvs.router.js';
import simulationsRouter from '@modules/simulations/simulations.router.js';
import recommendationsRouter from '@modules/recommendations/recommendations.router.js';
import anomaliesRouter from '@modules/anomalies/anomalies.router.js';
import notificationsRouter from '@modules/notifications/notifications.router.js';
import literacyRouter from '@modules/literacy/literacy.router.js';
import vaultsRouter from '@modules/vaults/vaults.router.js';
import communityRouter from '@modules/community/community.router.js';
import rewardsRouter from '@modules/rewards/rewards.router.js';

const app: any = express();

app.use(cors({ origin: env.CORS_ORIGIN, credentials: true }));
app.use(helmet());
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(generalLimiter);

app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'LifeGuard Finance API',
}));

app.get('/api/health', (_req: any, res: any) => {
  res.json({ success: true, message: 'LifeGuard Finance API is running', timestamp: new Date().toISOString() });
});

app.use(`${API_PREFIX}/auth`, authRouter);
app.use(`${API_PREFIX}/users`, usersRouter);
app.use(`${API_PREFIX}/profiles`, profilesRouter);
app.use(`${API_PREFIX}/incomes`, incomesRouter);
app.use(`${API_PREFIX}/expenses`, expensesRouter);
app.use(`${API_PREFIX}/debts`, debtsRouter);
app.use(`${API_PREFIX}/dependents`, dependentsRouter);
app.use(`${API_PREFIX}/protections`, protectionsRouter);
app.use(`${API_PREFIX}/fvs`, fvsRouter);
app.use(`${API_PREFIX}/simulations`, simulationsRouter);
app.use(`${API_PREFIX}/recommendations`, recommendationsRouter);
app.use(`${API_PREFIX}/anomalies`, anomaliesRouter);
app.use(`${API_PREFIX}/notifications`, notificationsRouter);
app.use(`${API_PREFIX}/literacy`, literacyRouter);
app.use(`${API_PREFIX}/vaults`, vaultsRouter);
app.use(`${API_PREFIX}/community`, communityRouter);
app.use(`${API_PREFIX}/rewards`, rewardsRouter);

app.use((_req: any, res: any) => {
  sendError(res, 'Route not found', 404);
});

app.use(errorHandler);

export default app;
