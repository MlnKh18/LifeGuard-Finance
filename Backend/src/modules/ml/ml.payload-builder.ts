import type { User, Income, Expense, Debt, Dependent, Protection, FvsResult } from '@prisma/client';
import type {
  FvsCalculateRequest,
  RecommendationGenerateRequest,
  AnomalyDetectRequest,
  SimulationRunRequest,
} from './ml.types.js';

export function buildFvsPayload(
  user: User,
  incomes: Income[],
  expenses: Expense[],
  debts: Debt[],
  dependents: Dependent[],
  protections: Protection[],
): FvsCalculateRequest {
  const calculateMonthlyAmount = (amount: number, frequency: string): number => {
    switch (frequency) {
      case 'DAILY': return amount * 30;
      case 'WEEKLY': return amount * 4;
      case 'BIWEEKLY': return amount * 2;
      case 'MONTHLY': return amount * 1;
      case 'QUARTERLY': return amount / 3;
      case 'SEMI_ANNUALLY': return amount / 6;
      case 'ANNUALLY': return amount / 12;
      default: return 0;
    }
  };

  const monthly_income = incomes.filter(i => i.isActive).reduce((sum, i) => sum + calculateMonthlyAmount(Number(i.amount), i.frequency), 0);
  const monthly_expenses = expenses.reduce((sum, e) => sum + Number(e.amount), 0);
  const total_debt = debts.reduce((sum, d) => sum + Number(d.remainingBalance), 0);
  const number_of_dependents = dependents.length;
  const protection_coverage = protections.filter(p => p.isActive).reduce((sum, p) => sum + Number(p.coverageAmount), 0);
  const emergency_fund = protections.filter(p => p.type === 'EMERGENCY_FUND' && p.isActive).reduce((sum, p) => sum + Number(p.coverageAmount), 0);

  return {
    monthly_income,
    monthly_expenses,
    total_debt,
    number_of_dependents,
    protection_coverage,
    emergency_fund,
  };
}

export function buildRecommendationPayload(
  userId: string,
  fvsResult: FvsResult,
  incomes: Income[],
  expenses: Expense[],
  debts: Debt[],
  protections: Protection[],
): RecommendationGenerateRequest {
  return {
    userId,
    fvsScore: Number(fvsResult.score),
    fvsCategory: fvsResult.category,
    incomes: incomes.map((i) => ({
      source: i.source,
      amount: Number(i.amount),
      frequency: i.frequency,
    })),
    expenses: expenses.map((e) => ({
      category: e.category,
      amount: Number(e.amount),
      date: e.date.toISOString(),
    })),
    debts: debts.map((d) => ({
      creditor: d.creditor,
      remainingBalance: Number(d.remainingBalance),
      interestRate: Number(d.interestRate),
      monthlyPayment: Number(d.monthlyPayment),
    })),
    protections: protections.map((p) => ({
      type: p.type,
      coverageAmount: Number(p.coverageAmount),
      premium: Number(p.premium),
    })),
  };
}

export function buildAnomalyPayload(
  userId: string,
  expenses: (Expense & { id: string })[],
  lookbackDays?: number,
): AnomalyDetectRequest {
  return {
    userId,
    expenses: expenses.map((e) => ({
      id: e.id,
      category: e.category,
      amount: Number(e.amount),
      date: e.date.toISOString(),
      description: e.description ?? undefined,
    })),
    lookbackDays,
  };
}

export function buildSimulationPayload(
  userId: string,
  type: string,
  parameters: Record<string, unknown>,
  financials: {
    totalIncome: number;
    totalExpenses: number;
    totalDebt: number;
    totalProtection: number;
    fvsScore?: number;
  },
): SimulationRunRequest {
  return {
    userId,
    type,
    parameters,
    currentFinancials: financials,
  };
}
