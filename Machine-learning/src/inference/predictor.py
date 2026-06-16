import numpy as np
from datetime import datetime, timezone

from src.config.constants import (
    FVS_WEIGHTS,
    INDICATOR_NAMES,
    CATEGORY_THRESHOLDS,
)
from src.features.engineer import feature_engineer
from src.models.rule_based import rule_based_calculator
from src.schemas.fvs import (
    FvsCalculateRequest,
    FvsCalculateResponse,
    FvsCalculateData,
)
from src.utils.versioning import version_manager


class FVSPredictor:
    """Produces FVS predictions using the best available model (ML or rule-based fallback)."""

    def __init__(self) -> None:
        self.model = None
        self.scaler = None
        self.metadata = None
        self._load_model()

    def _load_model(self) -> None:
        model, scaler, metadata = version_manager.load_model()
        if model is not None:
            self.model = model
            self.scaler = scaler
            self.metadata = metadata

    def reload(self) -> None:
        self._load_model()

    @property
    def model_version(self) -> str:
        if self.metadata:
            return self.metadata.get("model_version", "rule-v1.0.0")
        return "rule-v1.0.0"

    @property
    def is_ml_model(self) -> bool:
        return self.model is not None

    @staticmethod
    def _get_category(fvs_score: float) -> str:
        for threshold, category in CATEGORY_THRESHOLDS:
            if fvs_score >= threshold:
                return category
        return "Critical"

    def predict(self, request: FvsCalculateRequest) -> FvsCalculateResponse:
        indicators = feature_engineer.compute_all(
            monthly_income=request.monthly_income,
            monthly_expenses=request.monthly_expenses,
            total_debt=request.total_debt,
            number_of_dependents=request.number_of_dependents,
            protection_coverage=request.protection_coverage,
            emergency_fund=request.emergency_fund,
        )

        if self.is_ml_model:
            return self._predict_ml(indicators, request)
        else:
            return self._predict_rule_based(request)

    def _predict_ml(self, indicators: dict[str, float], request: FvsCalculateRequest) -> FvsCalculateResponse:
        feature_values = np.array(
            [[indicators[name] for name in INDICATOR_NAMES]]
        )

        model_type = self.metadata.get("model_type", "") if self.metadata else ""
        needs_scaling = model_type == "linear_regression"

        if needs_scaling and self.scaler is not None:
            feature_values = self.scaler.transform(feature_values)

        raw_prediction = self.model.predict(feature_values)[0]
        fvs_score = round(float(np.clip(raw_prediction, 0, 100)), 2)
        category = self._get_category(fvs_score)

        # Generate explanation based on rules & predicted score
        explanation = rule_based_calculator.generate_explanation(indicators, fvs_score, category)

        # Get feature importance from metadata or fallback to weights
        feature_importance = {}
        if self.metadata and "feature_importance" in self.metadata and self.metadata["feature_importance"]:
            feature_importance = self.metadata["feature_importance"]
        else:
            feature_importance = {name: FVS_WEIGHTS[name] for name in INDICATOR_NAMES}

        return FvsCalculateResponse(
            success=True,
            model_version=self.model_version,
            data=FvsCalculateData(
                score=fvs_score,
                category=category,
                indicators=indicators,
                feature_importance=feature_importance,
                explanation=explanation,
            ),
        )

    def _predict_rule_based(self, request: FvsCalculateRequest) -> FvsCalculateResponse:
        return rule_based_calculator.calculate(
            monthly_income=request.monthly_income,
            monthly_expenses=request.monthly_expenses,
            total_debt=request.total_debt,
            number_of_dependents=request.number_of_dependents,
            protection_coverage=request.protection_coverage,
            emergency_fund=request.emergency_fund,
        )


fvs_predictor = FVSPredictor()
