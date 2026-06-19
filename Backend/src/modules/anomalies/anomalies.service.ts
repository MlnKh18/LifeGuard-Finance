import { prisma } from '@shared/prisma/client.js';
import { expensesRepository } from '@modules/expenses/expenses.repository.js';
import { mlAdapter } from '@modules/ml/ml.adapter.js';
import { buildAnomalyPayload } from '@modules/ml/ml.payload-builder.js';
import { AppError } from '@shared/utils/app-error.js';
import type { AnomalySeverity } from '@prisma/client';
import type { PaginationParams } from '@shared/utils/pagination.js';

export class AnomaliesService {
  async detect(userId: string) {
    const expenses = await expensesRepository.findAllByUserId(userId);
    if (expenses.length === 0) throw AppError.badRequest('No expenses found to analyze');

    // Group expenses by date (YYYY-MM-DD)
    const now = new Date();
    // Consider current week as the last 7 days
    const currentWeekStart = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const expenseByDate = new Map<string, { date: Date; amount: number; isCurrentWeek: boolean }>();
    
    for (const exp of expenses) {
      const d = new Date(exp.date);
      const dateKey = `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
      if (!expenseByDate.has(dateKey)) {
        expenseByDate.set(dateKey, { date: d, amount: 0, isCurrentWeek: d >= currentWeekStart });
      }
      expenseByDate.get(dateKey)!.amount += Number(exp.amount);
    }

    // Group historical daily totals by day of the week (0 = Sunday ... 6 = Saturday)
    const totalsByDayOfWeek = new Map<number, number[]>();
    for (const val of expenseByDate.values()) {
      if (!val.isCurrentWeek) {
         const dow = val.date.getDay();
         if (!totalsByDayOfWeek.has(dow)) totalsByDayOfWeek.set(dow, []);
         totalsByDayOfWeek.get(dow)!.push(val.amount);
      }
    }

    const detectedAnomalies: any[] = [];
    const dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    for (const val of expenseByDate.values()) {
      if (val.isCurrentWeek) {
         const dow = val.date.getDay();
         const historicals = totalsByDayOfWeek.get(dow) || [];
         if (historicals.length > 0) {
            const sum = historicals.reduce((a, b) => a + b, 0);
            const avg = sum / historicals.length;
            
            if (avg > 0) {
               const increase = ((val.amount - avg) / avg) * 100;
               if (increase > 30) {
                 const severity = increase > 50 ? 'HIGH' : 'MEDIUM';
                 detectedAnomalies.push({
                   type: 'UNUSUAL_SPENDING',
                   severity: severity as AnomalySeverity,
                   description: `Pengeluaran hari ${dayNames[dow]} ini naik ${Math.round(increase)}% dari rata-rata hari ${dayNames[dow]} biasanya.`,
                   amount: val.amount,
                   expectedRange: [0, avg * 1.3],
                   metadata: { dayOfWeek: dow, increasePercentage: increase, historicalAverage: avg, date: val.date }
                 });
               }
            }
         }
      }
    }

    if (detectedAnomalies.length > 0) {
      await prisma.expenseAnomaly.createMany({
        data: detectedAnomalies.map((a) => ({
          userId,
          type: a.type,
          severity: a.severity,
          description: a.description,
          amount: a.amount,
          expectedRange: a.expectedRange,
          metadata: a.metadata,
        })),
      });
    }

    return { anomaliesFound: detectedAnomalies.length, anomalies: detectedAnomalies };
  }

  async list(userId: string, pagination: PaginationParams) {
    const [data, total] = await Promise.all([
      prisma.expenseAnomaly.findMany({ where: { userId }, skip: pagination.skip, take: pagination.take, orderBy: { createdAt: 'desc' }, include: { expense: true } }),
      prisma.expenseAnomaly.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async getById(id: string, userId: string) {
    const a = await prisma.expenseAnomaly.findUnique({ where: { id }, include: { expense: true } });
    if (!a || a.userId !== userId) throw AppError.notFound('Anomaly not found');
    return a;
  }
}

export const anomaliesService = new AnomaliesService();
