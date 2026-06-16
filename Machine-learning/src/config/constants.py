FVS_WEIGHTS = {
    "income_stability": 0.20,
    "expense_ratio": 0.15,
    "emergency_fund_coverage": 0.20,
    "debt_burden_ratio": 0.20,
    "dependent_load": 0.10,
    "protection_readiness": 0.10,
    "shock_absorption_capacity": 0.05,
}

INDICATOR_NAMES = [
    "income_stability",
    "expense_ratio",
    "emergency_fund_coverage",
    "debt_burden_ratio",
    "dependent_load",
    "protection_readiness",
    "shock_absorption_capacity",
]

CATEGORY_THRESHOLDS = [
    (80, "Safe"),
    (60, "Moderate"),
    (40, "Warning"),
    (0, "Critical"),
]

STATUS_THRESHOLDS = {
    "GOOD": 70,
    "WARNING": 40,
    "CRITICAL": 0,
}

FREQUENCY_TO_MONTHLY = {
    "DAILY": 30.0,
    "WEEKLY": 4.33,
    "BIWEEKLY": 2.17,
    "MONTHLY": 1.0,
    "QUARTERLY": 1.0 / 3.0,
    "SEMI_ANNUALLY": 1.0 / 6.0,
    "ANNUALLY": 1.0 / 12.0,
    "ONE_TIME": 1.0 / 12.0,
}

IDEAL_EMERGENCY_FUND_MONTHS = 6.0
IDEAL_EXPENSE_RATIO = 0.70
IDEAL_DEBT_RATIO = 0.35
IDEAL_PROTECTION_RATIO = 0.10

TRAINING_SAMPLE_SIZE = 5000
RANDOM_STATE = 42
CV_FOLDS = 5
TEST_SIZE = 0.2

MODEL_HYPERPARAMS = {
    "random_forest": {
        "n_estimators": 200,
        "max_depth": 10,
        "min_samples_split": 5,
        "min_samples_leaf": 2,
        "random_state": RANDOM_STATE,
    },
    "xgboost": {
        "n_estimators": 200,
        "max_depth": 6,
        "learning_rate": 0.1,
        "subsample": 0.8,
        "colsample_bytree": 0.8,
        "random_state": RANDOM_STATE,
    },
}
