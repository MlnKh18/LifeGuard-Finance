import { env } from '@shared/utils/env.js';
import { AppError } from '@shared/utils/app-error.js';

interface MlRequestOptions {
  endpoint: string;
  body: unknown;
  timeoutMs?: number;
}

export class MlClient {
  private baseUrl: string;
  private defaultTimeout: number;

  constructor() {
    this.baseUrl = env.ML_SERVICE_URL;
    this.defaultTimeout = 30000;
  }

  async post<T>(options: MlRequestOptions): Promise<T> {
    const { endpoint, body, timeoutMs } = options;
    const url = `${this.baseUrl}${endpoint}`;
    const timeout = timeoutMs ?? this.defaultTimeout;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      if (!response.ok) {
        const errorBody = await response.text().catch(() => 'Unknown error');
        throw AppError.serviceUnavailable(
          `ML service error (${response.status}): ${errorBody}`,
        );
      }

      const data = await response.json();
      return data as T;
    } catch (error) {
      if (error instanceof AppError) throw error;

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppError.serviceUnavailable('ML service request timed out');
      }

      throw AppError.serviceUnavailable(
        `ML service unavailable: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

export const mlClient = new MlClient();
