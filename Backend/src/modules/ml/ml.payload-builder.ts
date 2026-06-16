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
  return {
    userId: user.id,
    profile: {
      displayName: user.displayName,
      email: user.email,
    },
    incomes: incomes.map((i) => ({
      source: i.source,
      amount: Number(i.amount),
      frequency: i.frequency,
      isActive: i.isActive,
    })),
    expenses: expenses.map((e) => ({
      category: e.category,
      amount: Number(e.amount),
      date: e.date.toISOString(),
      isRecurring: e.isRecurring,
    })),
    debts: debts.map((d) => ({
      creditor: d.creditor,
      principal: Number(d.principal),
      remainingBalance: Number(d.remainingBalance),
      interestRate: Number(d.interestRate),
      monthlyPayment: Number(d.monthlyPayment),
      status: d.status,
    })),
    dependents: dependents.map((d) => ({
      name: d.name,
      relationship: d.relationship,
      needsEducation: d.needsEducation,
      monthlyCost: d.monthlyCost ? Number(d.monthlyCost) : null,
    })),
    protections: protections.map((p) => ({
      type: p.type,
      coverageAmount: Number(p.coverageAmount),
      premium: Number(p.premium),
      isActive: p.isActive,
    })),
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
