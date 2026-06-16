export const API_VERSION = 'v1';
export const API_PREFIX = `/api/${API_VERSION}`;

export const DEFAULT_PAGE = 1;
export const DEFAULT_LIMIT = 20;
export const MAX_LIMIT = 100;

export const CACHE_TTL = {
  LITERACY_MODULES: 15 * 60 * 1000,
  REWARD_RULES: 15 * 60 * 1000,
  COMMUNITY_METADATA: 5 * 60 * 1000,
} as const;

export const RATE_LIMIT = {
  GENERAL: { windowMs: 15 * 60 * 1000, max: 100 },
  AUTH: { windowMs: 15 * 60 * 1000, max: 30 },
  ML: { windowMs: 15 * 60 * 1000, max: 10 },
  WRITE: { windowMs: 15 * 60 * 1000, max: 50 },
} as const;

export const REWARD_POINTS = {
  PROFILE_COMPLETED: 100,
  FVS_CALCULATED: 50,
  VAULT_CREATED: 30,
  VAULT_MILESTONE: 50,
  LITERACY_COMPLETED: 25,
  COMMUNITY_POST: 10,
  COMMUNITY_COMMENT: 5,
  STREAK_LOGIN: 15,
  FIRST_INCOME: 20,
  FIRST_EXPENSE: 20,
  FIRST_DEBT: 20,
  FIRST_PROTECTION: 20,
} as const;

export const ML_ENDPOINTS = {
  FVS_CALCULATE: '/fvs/calculate',
  RECOMMENDATIONS_GENERATE: '/recommendations/generate',
  ANOMALIES_DETECT: '/anomalies/detect',
  SIMULATIONS_RUN: '/simulations/run',
} as const;

export const SOFT_DELETE_MODELS = [
  'User',
  'FamilyProfile',
  'Income',
  'Expense',
  'Debt',
  'Dependent',
  'Protection',
  'SavingsVault',
  'CommunityPost',
  'CommunityComment',
  'SimulationResult',
] as const;
