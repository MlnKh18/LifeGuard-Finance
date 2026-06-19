# 🧠 LifeGuard Finance — FVS Machine Learning Service

The artificial intelligence engine for the **LifeGuard Finance** platform. This service computes the **Financial Vulnerability Score (FVS)**, detects transaction anomalies, generates budget recommendations, and executes future cash flow simulations.

---

## 🔍 System Overview

To provide fast, accurate, and explainable financial advising, this service operates a dual-stage architecture:

1. **Rule-Based Engine**: Computes deterministic indicator scores using weighted mathematical models based on official personal finance metrics.
2. **Machine Learning Regressors**: Implements regression algorithms (Linear Regression, Random Forest, XGBoost) trained against rule-based data to predict vulnerability score fluctuations and flag out-of-bound variables.

The engine exposes a high-performance REST API built on FastAPI, consumed natively by the Express.js gateway.

---

## 🛠️ Technology Stack

* **Language**: Python 3.12+
* **Framework**: FastAPI (Asynchronous REST API)
* **Data Processing**: Pandas & NumPy
* **Machine Learning**: Scikit-Learn & XGBoost
* **Data Validation**: Pydantic
* **Serialization**: Joblib (Model persistence)
* **Web Server**: Uvicorn

---

## 📂 Project Structure

```text
Machine-learning/
├── main.py                    # Uvicorn production server entry point
├── requirements.txt           # Python package dependencies manifest
├── .env.example               # Environmental configuration template
├── artifacts/                 # Serialized model weights (Joblib binaries)
├── data/                      # Auto-generated synthetic datasets for training
├── docs/                      # Technical specification documents
│   ├── api-verification.md    # API test scenarios and scripts
│   ├── backend-integration.md # JSON integration schemas
│   └── postman-collection.json# Postman test suite
├── notebooks/                 # Jupyter notebooks for model prototyping
└── src/
    ├── api/
    │   ├── app.py             # FastAPI application configuration
    │   └── routes.py          # API route definitions
    ├── schemas/
    │   └── fvs.py             # Pydantic validation schemas
    ├── features/
    │   └── engineer.py        # Feature engineering & scaling pipelines
    ├── models/
    │   ├── rule_based.py      # Core heuristic FVS calculators
    │   └── ml_models.py       # ML Model configurations and wrapper classes
    ├── training/
    │   └── pipeline.py        # Automated training pipeline script
    ├── inference/
    │   └── predictor.py       # ML score prediction client
    ├── evaluation/
    │   └── evaluator.py       # Model performance metric logging
    ├── datasets/
    │   └── generator.py       # Synthetic user profile generators
    ├── utils/
    │   └── versioning.py      # Artifact model version manager
    └── config/
        ├── settings.py        # Pydantic-based settings loader
        └── constants.py       # Heuristic weights & risk ranges
```

---

## 📊 Financial Vulnerability Score (FVS) Formula

The Financial Vulnerability Score evaluates a user's resilience across seven weighted financial dimensions:

$$\text{FVS} = 0.20 \times S_1 + 0.15 \times S_2 + 0.20 \times S_3 + 0.20 \times S_4 + 0.10 \times S_5 + 0.10 \times S_6 + 0.05 \times S_7$$

### Indicator Variables ($S_1 - S_7$)

| Code | Indicator | Weight | Ideal Condition / Threshold |
|:---:|:---|:---:|:---|
| **$S_1$** | Income Stability | 0.20 | Income meets or exceeds the local standard living wage. |
| **$S_2$** | Expense Ratio | 0.15 | Monthly expenses relative to total monthly income (Ideal: $\le 30\%$). |
| **$S_3$** | Emergency Fund | 0.20 | Months of monthly expenditures covered by savings (Ideal: $\ge 6$ months). |
| **$S_4$** | Debt Burden | 0.20 | Estimated debt payment burden relative to monthly income. |
| **$S_5$** | Dependent Load | 0.10 | Cost load per dependent (est. 1.5M IDR each) relative to income. |
| **$S_6$** | Protection Readiness | 0.10 | Total insurance protection coverage relative to annual income (Ideal: $\ge 5\times$). |
| **$S_7$** | Shock Absorption | 0.05 | Residual surplus cash remaining after all debt & expenses are cleared. |

---

## ⚠️ Score Risk Classifications

Based on the calculated FVS ($0 - 100$), users are placed in one of the following risk classes:

| Class | FVS Range | Vulnerability Level & Description |
|:---|:---:|:---|
| 🟢 **Safe** | $80 - 100$ | Excellent resiliency. High savings buffer, low debt ratio, and sufficient insurance. |
| 🟡 **Moderate**| $60 - 79$ | Stable foundation, but with minor protection or saving gaps. |
| 🟠 **Warning** | $40 - 59$ | Tight cash flow. Low savings buffer, high risk from unexpected financial shocks. |
| 🔴 **Critical**| $0 - 39$ | Severely vulnerable. No emergency fund, high debt burden, immediate action needed. |

---

## 🚀 Installation & Local Execution

Setup the Python API server locally:

### 1. Prerequisites
Ensure **Python 3.12+** is installed on your machine.

### 2. Configure Virtual Environment
Initialize and activate your environment:
```bash
# Generate the environment folder
python -m venv venv

# Activate on Windows (PowerShell/CMD):
.\venv\Scripts\activate

# Activate on macOS/Linux:
source venv/bin/activate
```

### 3. Install Packages
```bash
pip install -r requirements.txt
```

### 4. Setup Environment
Copy the settings template:
```bash
cp .env.example .env
```

### 5. Train Models & Generate Artifacts
Run the end-to-end ML pipeline. This script generates synthetic data, trains the models, evaluates metrics, and serializes the best performing algorithms into `artifacts/`:
```bash
python -m src.training.pipeline
```

### 6. Run the FastAPI Server
Start Uvicorn to host the app:
```bash
python main.py
```
* The ML Service will start running on `http://localhost:8000`.
* FastAPI auto-generated interactive documentation is available at `http://localhost:8000/docs`.

---

## ⚡ API Endpoints

### 1. Health Status
* **Endpoint**: `GET /health`
* **Response**:
  ```json
  { "status": "healthy" }
  ```

### 2. Version Information
* **Endpoint**: `GET /model/version`
* **Response**:
  ```json
  {
    "model_version": "linear_regression-v1.0.0",
    "supported_models": ["linear_regression", "random_forest", "xgboost"]
  }
  ```

### 3. Calculate FVS Score
* **Endpoint**: `POST /fvs/calculate`
* **Headers**: `Content-Type: application/json`
* **Request Payload**:
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
* **Success Response**:
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
        "income_stability": 0.20,
        "expense_ratio": 0.15,
        "emergency_fund_coverage": 0.20,
        "debt_burden_ratio": 0.20,
        "dependent_load": 0.10,
        "protection_readiness": 0.10,
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

---

## ⚙️ Backend Integration

The Node.js/Express gateway acts as a client to this ML Service. Ensure your Express configuration `.env` file points to this server:
```env
ML_SERVICE_URL=http://localhost:8000
```
For deep structure models, see the integration blueprint at `docs/backend-integration.md`.