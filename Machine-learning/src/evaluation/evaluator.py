import numpy as np
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

from src.config.constants import INDICATOR_NAMES


class ModelEvaluator:
    """Evaluates trained models and produces comparison reports."""

    def evaluate(self, model, X, y, model_name: str, needs_scaling: bool = False, scaler=None) -> dict:
        if needs_scaling and scaler is not None:
            X_input = scaler.transform(X)
        else:
            X_input = X

        y_pred = model.predict(X_input)
        y_pred = np.clip(y_pred, 0, 100)

        mae = float(mean_absolute_error(y, y_pred))
        rmse = float(np.sqrt(mean_squared_error(y, y_pred)))
        r2 = float(r2_score(y, y_pred))

        feature_importance = None
        if hasattr(model, "feature_importances_"):
            importances = model.feature_importances_
            feature_importance = {
                INDICATOR_NAMES[i]: round(float(importances[i]), 4)
                for i in range(len(INDICATOR_NAMES))
            }
        elif hasattr(model, "coef_"):
            coefs = np.abs(model.coef_)
            total = coefs.sum()
            if total > 0:
                normalized = coefs / total
                feature_importance = {
                    INDICATOR_NAMES[i]: round(float(normalized[i]), 4)
                    for i in range(len(INDICATOR_NAMES))
                }

        return {
            "model_name": model_name,
            "mae": round(mae, 4),
            "rmse": round(rmse, 4),
            "r2": round(r2, 4),
            "feature_importance": feature_importance,
        }

    def compare(self, results: list[dict]) -> dict:
        comparison = {
            "models": results,
            "best_model": min(results, key=lambda r: r["rmse"])["model_name"],
            "ranking": sorted(results, key=lambda r: r["rmse"]),
        }
        return comparison


model_evaluator = ModelEvaluator()
