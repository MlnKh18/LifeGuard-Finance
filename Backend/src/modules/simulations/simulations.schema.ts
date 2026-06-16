import { z } from 'zod';

export const createSimulationSchema = z.object({
  type: z.enum(['DEBT_PAYOFF', 'SAVINGS_GOAL', 'EXPENSE_REDUCTION', 'INCOME_INCREASE', 'INSURANCE_COVERAGE', 'EMERGENCY_FUND', 'RETIREMENT', 'CUSTOM']),
  title: z.string().max(200).optional(),
  parameters: z.record(z.unknown()),
});

export type CreateSimulationInput = z.infer<typeof createSimulationSchema>;
