# Backend Integration Guide

## 1. API Contract Verification

The ML service response schema is designed to match the new flat request and nested response contract:

### Request Structure
```json
{
  "monthly_income": 10000000.0,
  "monthly_expenses": 3000000.0,
  "total_debt": 20000000.0,
  "number_of_dependents": 2,
  "protection_coverage": 50000000.0,
  "emergency_fund": 15000000.0
}
```

### Response Structure
```json
{
  "success": true,
  "model_version": "linear_regression-v1.0.0",
  "data": {
    "score": 84.0,
    "category": "Safe",
    "indicators": {
      "income_stability": 100.0,
      "expense_ratio": 100.0,
      "emergency_fund_coverage": 83.33,
      "debt_burden_ratio": 100.0,
      "dependent_load": 65.0,
      "protection_readiness": 8.33,
      "shock_absorption_capacity": 100.0
    },
    "feature_importance": {
      "income_stability": 0.2,
      "expense_ratio": 0.15,
      "emergency_fund_coverage": 0.2,
      "debt_burden_ratio": 0.2,
      "dependent_load": 0.1,
      "protection_readiness": 0.1,
      "shock_absorption_capacity": 0.05
    },
    "explanation": {
      "summary": "Your financial profile is resilient with a score of 84.0...",
      "strengths": ["..."],
      "vulnerabilities": ["..."]
    }
  }
}
```

## 2. Response Mapping Strategy
The backend can map these fields to database model fields:
- `data.score` -> mapped to DB decimal score.
- `data.category` -> mapped to backend vulnerability category enum (`Safe`, `Moderate`, `Warning`, `Critical`).
- `model_version` -> logged/stored for model metadata tracking.

## 3. Error Handling Strategy

| Scenario | ML Service Response | Backend Handling |
|---|---|---|
| Valid request | 200 + JSON body | Stores result in DB |
| Validation error | 422 + `detail` field | throws validation error |
| Server error | 500 + `detail` field | throws internal server error |
| Network failure | Connection refused | triggers failover / fallback logic |

## 4. Timeout Handling Strategy
- Backend default timeout: **10-30 seconds** (configured in `ml.client.ts`)
- ML service typical response time: **< 100ms** (rule-based), **< 200ms** (ML model)
- If timeout occurs, triggers fallback to rule-based offline formula or throw client-facing connection error.

## 5. API Compatibility Checklist
- [x] Input schema uses flat names (`monthly_income`, `monthly_expenses`, `total_debt`, `number_of_dependents`, `protection_coverage`, `emergency_fund`)
- [x] Output matches nested format under `success`, `model_version`, and `data`
- [x] Risk categories match: `Safe`, `Moderate`, `Warning`, `Critical`
- [x] Response includes explainability data (`explanation` object with strengths/vulnerabilities)
