import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import cross_val_score
from xgboost import XGBRegressor

from src.config.constants import (
    INDICATOR_NAMES,
    MODEL_HYPERPARAMS,
    RANDOM_STATE,
    CV_FOLDS,
)


class FVSModelTrainer:
    """Trains and compares 3 regression models for FVS prediction."""

    def __init__(self) -> None:
        self.models: dict = {}
        self.scaler = StandardScaler()
        self.feature_names = INDICATOR_NAMES
        self.best_model_name: str | None = None
        self.cv_results: dict = {}

    def _build_models(self) -> dict:
        return {
            "linear_regression": LinearRegression(),
            "random_forest": RandomForestRegressor(
                **MODEL_HYPERPARAMS["random_forest"]
            ),
            "xgboost": XGBRegressor(**MODEL_HYPERPARAMS["xgboost"]),
        }

    def train(self, df: pd.DataFrame) -> dict:
        X = df[self.feature_names].values
        y = df["fvs_score"].values

        X_scaled = self.scaler.fit_transform(X)

        candidates = self._build_models()
        results = {}

        for name, model in candidates.items():
            if name in ("random_forest", "xgboost"):
                model.fit(X, y)
            else:
                model.fit(X_scaled, y)

            cv_input = X if name in ("random_forest", "xgboost") else X_scaled

            rmse_scores = -cross_val_score(
                model if name in ("random_forest", "xgboost") else type(model)().fit(X_scaled, y),
                cv_input,
                y,
                cv=CV_FOLDS,
                scoring="neg_root_mean_squared_error",
            )

            mae_scores = -cross_val_score(
                model if name in ("random_forest", "xgboost") else type(model)().fit(X_scaled, y),
                cv_input,
                y,
                cv=CV_FOLDS,
                scoring="neg_mean_absolute_error",
            )

            r2_scores = cross_val_score(
                model if name in ("random_forest", "xgboost") else type(model)().fit(X_scaled, y),
                cv_input,
                y,
                cv=CV_FOLDS,
                scoring="r2",
            )

            results[name] = {
                "model": model,
                "cv_rmse_mean": float(np.mean(rmse_scores)),
                "cv_rmse_std": float(np.std(rmse_scores)),
                "cv_mae_mean": float(np.mean(mae_scores)),
                "cv_mae_std": float(np.std(mae_scores)),
                "cv_r2_mean": float(np.mean(r2_scores)),
                "cv_r2_std": float(np.std(r2_scores)),
            }

            self.models[name] = model

        self.cv_results = results

        best_name = min(results, key=lambda k: results[k]["cv_rmse_mean"])
        self.best_model_name = best_name

        return results

    def get_best_model(self):
        if self.best_model_name is None:
            raise RuntimeError("No models trained yet")
        return self.models[self.best_model_name]

    def get_feature_importance(self, model_name: str | None = None) -> dict[str, float] | None:
        name = model_name or self.best_model_name
        if name is None:
            return None

        model = self.models.get(name)
        if model is None:
            return None

        if hasattr(model, "feature_importances_"):
            importances = model.feature_importances_
            return {
                self.feature_names[i]: round(float(importances[i]), 4)
                for i in range(len(self.feature_names))
            }
        elif hasattr(model, "coef_"):
            coefs = np.abs(model.coef_)
            total = coefs.sum()
            if total == 0:
                return None
            normalized = coefs / total
            return {
                self.feature_names[i]: round(float(normalized[i]), 4)
                for i in range(len(self.feature_names))
            }
        return None
