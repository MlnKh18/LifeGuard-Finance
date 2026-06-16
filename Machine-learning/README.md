# LifeGuard Finance — FVS Machine Learning Service

Financial Vulnerability Score (FVS) calculation and prediction service for the LifeGuard Finance platform.

## Overview

This service computes the Financial Vulnerability Score using a two-stage approach:

1. **Rule-Based Engine** — Deterministic FVS calculation using the official weighted formula
2. **ML Models** — Trained regression models (Linear Regression, Random Forest, XGBoost) that learn from rule-based ground truth

The service exposes a REST API consumed by the Express.js backend.

## Tech Stack

- Python 3.12+
- FastAPI
- Pandas / NumPy
- Scikit-Learn / XGBoost
- Pydantic
- Joblib

## Project Structure

```
machine-learning/
├── main.py                    # Uvicorn entry point
├── requirements.txt           # Dependencies
├── .env.example               # Environment template
├── src/
│   ├── api/
│   │   ├── app.py             # FastAPI application
│   │   └── routes.py          # API endpoints
│   ├── schemas/
│   │   └── fvs.py             # Pydantic request/response models
│   ├── features/
│   │   └── engineer.py        # Feature engineering (S1–S7)
│   ├── models/
│   │   ├── rule_based.py      # Rule-based FVS calculator
│   │   └── ml_models.py       # ML model trainer
│   ├── training/
│   │   └── pipeline.py        # End-to-end training pipeline
│   ├── inference/
│   │   └── predictor.py       # Prediction engine
│   ├── evaluation/
│   │   └── evaluator.py       # Model evaluation
│   ├── datasets/
│   │   └── generator.py       # Synthetic data generator
│   ├── utils/
│   │   └── versioning.py      # Model artifact management
│   └── config/
│       ├── settings.py        # Environment settings
│       └── constants.py       # FVS weights & thresholds
├── artifacts/                 # Trained model files
├── data/                      # Generated datasets
├── docs/                      # Documentation
│   ├── api-verification.md    # Test scenarios
│   ├── backend-integration.md # Integration guide
│   └── postman-collection.json
└── notebooks/                 # Jupyter notebooks
```

## FVS Formula

```
FVS = 0.20×S1 + 0.15×S2 + 0.20×S3 + 0.20×S4 + 0.10×S5 + 0.10×S6 + 0.05×S7
```

| Code | Indicator | Weight | Description |
|------|-----------|--------|-------------|
| S1 | Income Stability | 0.20 | Income adequacy relative to standard living wage |
| S2 | Expense Ratio | 0.15 | Ratio of monthly expenses to monthly income (ideal <= 30%) |
| S3 | Emergency Fund | 0.20 | Months of monthly expenses covered by emergency fund (ideal >= 6 months) |
| S4 | Debt Burden | 0.20 | Monthly debt payments (estimated at 5% of total debt) relative to income |
| S5 | Dependent Load | 0.10 | Estimated monthly dependent cost (1,500,000 IDR per dependent) relative to income |
| S6 | Protection Readiness | 0.10 | Insurance coverage relative to annual income (ideal >= 5x) |
| S7 | Shock Absorption | 0.05 | Monthly surplus cash remaining after satisfying obligations |

## Risk Categories

| Category | Score Range | Description |
|----------|-------------|-------------|
| Safe | 80–100 | Exceptional resilience, low debt, high savings, fully insured |
| Moderate | 60–79 | Stable, but with minor gaps |
| Warning | 40–59 | Vulnerable; cash flow is tight, low emergency savings |
| Critical | 0–39 | High vulnerability; high debt load, no safety net |

## Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Copy environment config
cp .env.example .env

# Train ML models (generates artifacts/)
python -m src.training.pipeline

# Start service
python main.py
```

## API Endpoints

### Health Check
```
GET /health
```

### Model Version
```
GET /model/version
```

### Calculate FVS
```
POST /fvs/calculate
Content-Type: application/json

{
  "monthly_income": 10000000.0,
  "monthly_expenses": 3000000.0,
  "total_debt": 20000000.0,
  "number_of_dependents": 2,
  "protection_coverage": 50000000.0,
  "emergency_fund": 15000000.0
}
```

Response:
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
      "summary": "Your financial profile is resilient with a score of 84.0. Maintain your healthy savings and low debt levels.",
      "strengths": [
        "Healthy emergency fund provides a reliable buffer for unexpected expenses.",
        "Low debt-to-income ratio indicates highly manageable liability levels."
      ],
      "vulnerabilities": [
        "Minimal insurance coverage leaves you exposed to health or life disruptions."
      ]
    }
  }
}
```

## Backend Integration

The Express.js backend calls `POST /fvs/calculate`. Set `ML_SERVICE_URL` in the backend `.env`:

```env
ML_SERVICE_URL=http://localhost:8000
```

See `docs/backend-integration.md` for the full integration guide.

## Deployment

The service is designed for lightweight deployment:

```bash
# Production start
uvicorn src.api.app:app --host 0.0.0.0 --port 8000
```