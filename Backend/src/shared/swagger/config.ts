export const swaggerSpec = {
  openapi: '3.1.0',
  info: {
    title: 'LifeGuard Finance API',
    version: '1.0.0',
    description: 'Backend API for LifeGuard Finance — a mobile-first personal finance platform with AI-driven financial health monitoring.',
    contact: { name: 'LifeGuard Finance Team' },
  },
  servers: [
    { url: 'http://localhost:3000', description: 'Development' },
    { url: 'https://lifeguard-finance.vercel.app', description: 'Production' },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Firebase ID Token',
      },
    },
    schemas: {
      SuccessResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: true },
          message: { type: 'string', example: 'Success' },
          data: { type: 'object' },
          meta: { type: 'object' },
        },
      },
      ErrorResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: false },
          message: { type: 'string', example: 'Validation failed' },
          errors: { type: 'array', items: { type: 'object' } },
        },
      },
      PaginationMeta: {
        type: 'object',
        properties: {
          page: { type: 'integer', example: 1 },
          limit: { type: 'integer', example: 20 },
          total: { type: 'integer', example: 100 },
          totalPages: { type: 'integer', example: 5 },
          hasNext: { type: 'boolean', example: true },
          hasPrevious: { type: 'boolean', example: false },
        },
      },
      User: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          firebaseUid: { type: 'string' },
          email: { type: 'string', format: 'email' },
          displayName: { type: 'string', nullable: true },
          avatarUrl: { type: 'string', nullable: true },
          phoneNumber: { type: 'string', nullable: true },
          isActive: { type: 'boolean' },
          roles: { type: 'array', items: { type: 'string', enum: ['USER', 'ADMIN', 'MODERATOR'] } },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        },
      },
      Income: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          userId: { type: 'string', format: 'uuid' },
          source: { type: 'string' },
          amount: { type: 'number' },
          currency: { type: 'string' },
          frequency: { type: 'string', enum: ['DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'SEMI_ANNUALLY', 'ANNUALLY', 'ONE_TIME'] },
          description: { type: 'string', nullable: true },
          isActive: { type: 'boolean' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      Expense: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          userId: { type: 'string', format: 'uuid' },
          category: { type: 'string', enum: ['FOOD', 'TRANSPORTATION', 'HOUSING', 'UTILITIES', 'HEALTHCARE', 'EDUCATION', 'ENTERTAINMENT', 'SHOPPING', 'INSURANCE', 'SAVINGS', 'DEBT_PAYMENT', 'CHARITY', 'PERSONAL_CARE', 'TRAVEL', 'SUBSCRIPTIONS', 'OTHER'] },
          amount: { type: 'number' },
          currency: { type: 'string' },
          date: { type: 'string', format: 'date-time' },
          isRecurring: { type: 'boolean' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      FvsResult: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          userId: { type: 'string', format: 'uuid' },
          score: { type: 'number' },
          category: { type: 'string', enum: ['VERY_VULNERABLE', 'VULNERABLE', 'MODERATE', 'STABLE', 'VERY_STABLE'] },
          modelVersion: { type: 'string' },
          indicators: { type: 'array', items: { $ref: '#/components/schemas/FvsIndicator' } },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      FvsIndicator: {
        type: 'object',
        properties: {
          indicatorName: { type: 'string' },
          value: { type: 'number' },
          weight: { type: 'number' },
          status: { type: 'string' },
          description: { type: 'string', nullable: true },
        },
      },
    },
  },
  security: [{ BearerAuth: [] }],
  tags: [
    { name: 'Auth', description: 'Authentication & user sync' },
    { name: 'Users', description: 'User profile management' },
    { name: 'Profiles', description: 'Family profiles' },
    { name: 'Incomes', description: 'Income records' },
    { name: 'Expenses', description: 'Expense records' },
    { name: 'Debts', description: 'Debt obligations' },
    { name: 'Dependents', description: 'Dependent family members' },
    { name: 'Protections', description: 'Insurance & protections' },
    { name: 'FVS', description: 'Financial Vulnerability Score' },
    { name: 'Simulations', description: 'Financial simulations' },
    { name: 'Recommendations', description: 'ML-generated recommendations' },
    { name: 'Anomalies', description: 'Expense anomaly detection' },
    { name: 'Notifications', description: 'User notifications' },
    { name: 'Literacy', description: 'Financial literacy modules' },
    { name: 'Vaults', description: 'Savings vaults' },
    { name: 'Community', description: 'Community posts & comments' },
    { name: 'Rewards', description: 'Gamification rewards' },
  ],
  paths: {
    '/api/v1/auth/me': {
      get: { tags: ['Auth'], summary: 'Get current authenticated user', responses: { '200': { description: 'User info', content: { 'application/json': { schema: { $ref: '#/components/schemas/SuccessResponse' } } } }, '401': { description: 'Unauthorized', content: { 'application/json': { schema: { $ref: '#/components/schemas/ErrorResponse' } } } } } },
    },
    '/api/v1/auth/sync-user': {
      post: { tags: ['Auth'], summary: 'Sync Firebase user to database', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['firebaseUid', 'email'], properties: { firebaseUid: { type: 'string' }, email: { type: 'string', format: 'email' }, displayName: { type: 'string' }, avatarUrl: { type: 'string' } } } } } }, responses: { '201': { description: 'User synced' }, '400': { description: 'Validation error' } } },
    },
    '/api/v1/users/me': {
      get: { tags: ['Users'], summary: 'Get current user profile', responses: { '200': { description: 'User profile' } } },
      patch: { tags: ['Users'], summary: 'Update current user profile', requestBody: { content: { 'application/json': { schema: { type: 'object', properties: { displayName: { type: 'string' }, avatarUrl: { type: 'string' }, phoneNumber: { type: 'string' } } } } } }, responses: { '200': { description: 'Updated' } } },
    },
    '/api/v1/profiles': {
      get: { tags: ['Profiles'], summary: 'List family profiles', parameters: [{ name: 'page', in: 'query', schema: { type: 'integer' } }, { name: 'limit', in: 'query', schema: { type: 'integer' } }], responses: { '200': { description: 'Paginated profiles' } } },
      post: { tags: ['Profiles'], summary: 'Create family profile', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['name', 'relationship'], properties: { name: { type: 'string' }, relationship: { type: 'string' }, dateOfBirth: { type: 'string', format: 'date-time' }, notes: { type: 'string' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/profiles/{id}': {
      get: { tags: ['Profiles'], summary: 'Get profile by ID', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '200': { description: 'Profile' }, '404': { description: 'Not found' } } },
      patch: { tags: ['Profiles'], summary: 'Update profile', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Profiles'], summary: 'Delete profile', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/incomes': {
      get: { tags: ['Incomes'], summary: 'List incomes', parameters: [{ name: 'page', in: 'query', schema: { type: 'integer' } }, { name: 'limit', in: 'query', schema: { type: 'integer' } }, { name: 'frequency', in: 'query', schema: { type: 'string' } }], responses: { '200': { description: 'Paginated incomes' } } },
      post: { tags: ['Incomes'], summary: 'Create income', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['source', 'amount', 'frequency'], properties: { source: { type: 'string' }, amount: { type: 'number' }, frequency: { type: 'string', enum: ['DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'SEMI_ANNUALLY', 'ANNUALLY', 'ONE_TIME'] }, description: { type: 'string' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/incomes/{id}': {
      get: { tags: ['Incomes'], summary: 'Get income by ID', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Income' } } },
      patch: { tags: ['Incomes'], summary: 'Update income', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Incomes'], summary: 'Delete income', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/expenses': {
      get: { tags: ['Expenses'], summary: 'List expenses', parameters: [{ name: 'page', in: 'query', schema: { type: 'integer' } }, { name: 'category', in: 'query', schema: { type: 'string' } }, { name: 'startDate', in: 'query', schema: { type: 'string' } }, { name: 'endDate', in: 'query', schema: { type: 'string' } }], responses: { '200': { description: 'Paginated expenses' } } },
      post: { tags: ['Expenses'], summary: 'Create expense', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['category', 'amount'], properties: { category: { type: 'string' }, amount: { type: 'number' }, date: { type: 'string' }, description: { type: 'string' }, isRecurring: { type: 'boolean' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/expenses/{id}': {
      get: { tags: ['Expenses'], summary: 'Get expense', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Expense' } } },
      patch: { tags: ['Expenses'], summary: 'Update expense', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Expenses'], summary: 'Delete expense', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/debts': {
      get: { tags: ['Debts'], summary: 'List debts', responses: { '200': { description: 'Paginated debts' } } },
      post: { tags: ['Debts'], summary: 'Create debt', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['creditor', 'principal', 'remainingBalance', 'interestRate', 'monthlyPayment'], properties: { creditor: { type: 'string' }, principal: { type: 'number' }, remainingBalance: { type: 'number' }, interestRate: { type: 'number' }, monthlyPayment: { type: 'number' }, status: { type: 'string' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/debts/{id}': {
      get: { tags: ['Debts'], summary: 'Get debt', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Debt' } } },
      patch: { tags: ['Debts'], summary: 'Update debt', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Debts'], summary: 'Delete debt', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/dependents': {
      get: { tags: ['Dependents'], summary: 'List dependents', responses: { '200': { description: 'Paginated dependents' } } },
      post: { tags: ['Dependents'], summary: 'Create dependent', responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/dependents/{id}': {
      get: { tags: ['Dependents'], summary: 'Get dependent', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Dependent' } } },
      patch: { tags: ['Dependents'], summary: 'Update dependent', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Dependents'], summary: 'Delete dependent', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/protections': {
      get: { tags: ['Protections'], summary: 'List protections', responses: { '200': { description: 'Paginated protections' } } },
      post: { tags: ['Protections'], summary: 'Create protection', responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/protections/{id}': {
      get: { tags: ['Protections'], summary: 'Get protection', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Protection' } } },
      patch: { tags: ['Protections'], summary: 'Update protection', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Protections'], summary: 'Delete protection', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/fvs/calculate': {
      post: { tags: ['FVS'], summary: 'Calculate Financial Vulnerability Score', description: 'Loads all user financial data and sends to ML service for FVS calculation', responses: { '201': { description: 'FVS calculated', content: { 'application/json': { schema: { $ref: '#/components/schemas/FvsResult' } } } }, '503': { description: 'ML service unavailable' } } },
    },
    '/api/v1/fvs/history': {
      get: { tags: ['FVS'], summary: 'Get FVS history', responses: { '200': { description: 'Paginated FVS history' } } },
    },
    '/api/v1/fvs/latest': {
      get: { tags: ['FVS'], summary: 'Get latest FVS result', responses: { '200': { description: 'Latest FVS' }, '404': { description: 'No FVS calculated yet' } } },
    },
    '/api/v1/fvs/{id}': {
      get: { tags: ['FVS'], summary: 'Get FVS by ID', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'FVS result with indicators' } } },
    },
    '/api/v1/simulations': {
      get: { tags: ['Simulations'], summary: 'List simulations', responses: { '200': { description: 'Paginated simulations' } } },
      post: { tags: ['Simulations'], summary: 'Run simulation', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['type', 'parameters'], properties: { type: { type: 'string', enum: ['DEBT_PAYOFF', 'SAVINGS_GOAL', 'EXPENSE_REDUCTION', 'INCOME_INCREASE', 'INSURANCE_COVERAGE', 'EMERGENCY_FUND', 'RETIREMENT', 'CUSTOM'] }, title: { type: 'string' }, parameters: { type: 'object' } } } } } }, responses: { '201': { description: 'Simulation result' } } },
    },
    '/api/v1/simulations/{id}': {
      get: { tags: ['Simulations'], summary: 'Get simulation', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Simulation' } } },
      delete: { tags: ['Simulations'], summary: 'Delete simulation', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/recommendations': {
      get: { tags: ['Recommendations'], summary: 'List recommendations (auto-generates if none)', responses: { '200': { description: 'Recommendations' } } },
    },
    '/api/v1/recommendations/{id}': {
      get: { tags: ['Recommendations'], summary: 'Get recommendation', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Recommendation' } } },
    },
    '/api/v1/anomalies/detect': {
      post: { tags: ['Anomalies'], summary: 'Detect expense anomalies', responses: { '201': { description: 'Anomalies detected' } } },
    },
    '/api/v1/anomalies': {
      get: { tags: ['Anomalies'], summary: 'List anomalies', responses: { '200': { description: 'Paginated anomalies' } } },
    },
    '/api/v1/anomalies/{id}': {
      get: { tags: ['Anomalies'], summary: 'Get anomaly', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Anomaly detail' } } },
    },
    '/api/v1/notifications': {
      get: { tags: ['Notifications'], summary: 'List notifications', responses: { '200': { description: 'Paginated notifications' } } },
    },
    '/api/v1/notifications/{id}/read': {
      patch: { tags: ['Notifications'], summary: 'Mark notification as read', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Marked as read' } } },
    },
    '/api/v1/notifications/read-all': {
      patch: { tags: ['Notifications'], summary: 'Mark all notifications as read', responses: { '200': { description: 'All marked as read' } } },
    },
    '/api/v1/literacy': {
      get: { tags: ['Literacy'], summary: 'List literacy modules', parameters: [{ name: 'category', in: 'query', schema: { type: 'string' } }, { name: 'difficulty', in: 'query', schema: { type: 'string' } }], responses: { '200': { description: 'Paginated literacy modules' } } },
    },
    '/api/v1/literacy/{id}': {
      get: { tags: ['Literacy'], summary: 'Get literacy module', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Module detail' } } },
    },
    '/api/v1/vaults': {
      get: { tags: ['Vaults'], summary: 'List savings vaults', responses: { '200': { description: 'Paginated vaults' } } },
      post: { tags: ['Vaults'], summary: 'Create vault', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['name', 'targetAmount'], properties: { name: { type: 'string' }, targetAmount: { type: 'number' }, deadline: { type: 'string' }, color: { type: 'string' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/vaults/{id}': {
      get: { tags: ['Vaults'], summary: 'Get vault', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Vault' } } },
      patch: { tags: ['Vaults'], summary: 'Update vault', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Vaults'], summary: 'Delete vault', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/community/posts': {
      get: { tags: ['Community'], summary: 'List posts', parameters: [{ name: 'category', in: 'query', schema: { type: 'string' } }], responses: { '200': { description: 'Paginated posts' } } },
      post: { tags: ['Community'], summary: 'Create post', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['title', 'content'], properties: { title: { type: 'string' }, content: { type: 'string' }, category: { type: 'string' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/community/posts/{id}': {
      get: { tags: ['Community'], summary: 'Get post with comments', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Post with comments' } } },
      patch: { tags: ['Community'], summary: 'Update post', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Community'], summary: 'Delete post', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/community/comments': {
      post: { tags: ['Community'], summary: 'Create comment', requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['postId', 'content'], properties: { postId: { type: 'string' }, content: { type: 'string' } } } } } }, responses: { '201': { description: 'Created' } } },
    },
    '/api/v1/community/comments/{postId}': {
      get: { tags: ['Community'], summary: 'List comments for post', parameters: [{ name: 'postId', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Paginated comments' } } },
    },
    '/api/v1/community/comments/{id}': {
      patch: { tags: ['Community'], summary: 'Update comment', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Community'], summary: 'Delete comment', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { '200': { description: 'Deleted' } } },
    },
    '/api/v1/rewards': {
      get: { tags: ['Rewards'], summary: 'Get rewards summary', responses: { '200': { description: 'Points summary' } } },
    },
    '/api/v1/rewards/history': {
      get: { tags: ['Rewards'], summary: 'Get rewards history', responses: { '200': { description: 'Paginated reward history' } } },
    },
  },
};
