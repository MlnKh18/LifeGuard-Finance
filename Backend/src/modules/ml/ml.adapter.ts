import { mlClient } from './ml.client.js';
import { ML_ENDPOINTS } from '@shared/constants/index.js';
import type {
  FvsCalculateRequest,
  FvsCalculateResponse,
  RecommendationGenerateRequest,
  RecommendationGenerateResponse,
  AnomalyDetectRequest,
  AnomalyDetectResponse,
  SimulationRunRequest,
  SimulationRunResponse,
} from './ml.types.js';

export class MlAdapter {
  async calculateFvs(payload: FvsCalculateRequest): Promise<FvsCalculateResponse> {
    return mlClient.post<FvsCalculateResponse>({
      endpoint: ML_ENDPOINTS.FVS_CALCULATE,
      body: payload,
    });
  }

  async generateRecommendations(
    payload: RecommendationGenerateRequest,
  ): Promise<RecommendationGenerateResponse> {
    return mlClient.post<RecommendationGenerateResponse>({
      endpoint: ML_ENDPOINTS.RECOMMENDATIONS_GENERATE,
      body: payload,
    });
  }

  async detectAnomalies(payload: AnomalyDetectRequest): Promise<AnomalyDetectResponse> {
    return mlClient.post<AnomalyDetectResponse>({
      endpoint: ML_ENDPOINTS.ANOMALIES_DETECT,
      body: payload,
    });
  }

  async runSimulation(payload: SimulationRunRequest): Promise<SimulationRunResponse> {
    return mlClient.post<SimulationRunResponse>({
      endpoint: ML_ENDPOINTS.SIMULATIONS_RUN,
      body: payload,
    });
  }
}

export const mlAdapter = new MlAdapter();
