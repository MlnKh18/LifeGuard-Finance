export interface FvsCalculateRequest {
  monthly_income: number;
  monthly_expenses: number;
  total_debt: number;
  number_of_dependents: number;
  protection_coverage: number;
  emergency_fund: number;
}

export interface FvsIndicator {
  indicatorName: string;
  value: number;
  weight: number;
  status: string;
  description?: string;
}

export interface FvsCalculateResponse {
  success: boolean;
  model_version: string;
  data: {
    score: number;
    category: string;
    indicators: Record<string, number>;
    feature_importance: Record<string, number>;
    explanation: {
      summary: string;
      strengths: string[];
      vulnerabilities: string[];
    };
  };
}

export interface RecommendationGenerateRequest {
  userId: string;
  fvsScore: number;
  fvsCategory: string;
  incomes: Array<{
    source: string;
    amount: number;
    frequency: string;
  }>;
  expenses: Array<{
    category: string;
    amount: number;
    date: string;
  }>;
  debts: Array<{
    creditor: string;
    remainingBalance: number;
    interestRate: number;
    monthlyPayment: number;
  }>;
  protections: Array<{
    type: string;
    coverageAmount: number;
    premium: number;
  }>;
}

export interface RecommendationItem {
  category: string;
  title: string;
  description: string;
  priority: number;
  actionUrl?: string;
  metadata?: Record<string, unknown>;
}

export interface RecommendationGenerateResponse {
  recommendations: RecommendationItem[];
  modelVersion: string;
  generatedAt: string;
}

export interface AnomalyDetectRequest {
  userId: string;
  expenses: Array<{
    id: string;
    category: string;
    amount: number;
    date: string;
    description?: string;
  }>;
  lookbackDays?: number;
}

export interface AnomalyItem {
  expenseId?: string;
  type: string;
  severity: string;
  description: string;
  amount?: number;
  expectedRange?: {
    min: number;
    max: number;
  };
  metadata?: Record<string, unknown>;
}

export interface AnomalyDetectResponse {
  anomalies: AnomalyItem[];
  modelVersion: string;
  analyzedAt: string;
}

export interface SimulationRunRequest {
  userId: string;
  type: string;
  parameters: Record<string, unknown>;
  currentFinancials: {
    totalIncome: number;
    totalExpenses: number;
    totalDebt: number;
    totalProtection: number;
    fvsScore?: number;
  };
}

export interface SimulationRunResponse {
  type: string;
  title: string;
  result: Record<string, unknown>;
  modelVersion: string;
  simulatedAt: string;
}
