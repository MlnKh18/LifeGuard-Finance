import json
import os
from datetime import datetime, timezone

import joblib

from src.config.constants import INDICATOR_NAMES
from src.config.settings import settings


class ModelVersionManager:
    """Manages model artifact persistence and metadata."""

    def __init__(self, artifacts_dir: str | None = None) -> None:
        self.artifacts_dir = artifacts_dir or settings.ARTIFACTS_DIR
        os.makedirs(self.artifacts_dir, exist_ok=True)

    def save_model(
        self,
        model,
        scaler,
        model_name: str,
        version: str,
        metrics: dict,
        dataset_version: str = "v1.0.0",
    ) -> str:
        model_path = os.path.join(self.artifacts_dir, "best_model.joblib")
        scaler_path = os.path.join(self.artifacts_dir, "scaler.joblib")
        metadata_path = os.path.join(self.artifacts_dir, "model_metadata.json")

        joblib.dump(model, model_path)
        joblib.dump(scaler, scaler_path)

        metadata = {
            "model_version": version,
            "model_type": model_name,
            "trained_at": datetime.now(timezone.utc).isoformat(),
            "dataset_version": dataset_version,
            "feature_names": INDICATOR_NAMES,
            "metrics": metrics,
        }

        with open(metadata_path, "w") as f:
            json.dump(metadata, f, indent=2)

        return model_path

    def load_model(self):
        model_path = os.path.join(self.artifacts_dir, "best_model.joblib")
        scaler_path = os.path.join(self.artifacts_dir, "scaler.joblib")
        metadata_path = os.path.join(self.artifacts_dir, "model_metadata.json")

        if not os.path.exists(model_path):
            return None, None, None

        model = joblib.load(model_path)
        scaler = joblib.load(scaler_path) if os.path.exists(scaler_path) else None

        metadata = None
        if os.path.exists(metadata_path):
            with open(metadata_path) as f:
                metadata = json.load(f)

        return model, scaler, metadata

    def get_metadata(self) -> dict | None:
        metadata_path = os.path.join(self.artifacts_dir, "model_metadata.json")
        if not os.path.exists(metadata_path):
            return None
        with open(metadata_path) as f:
            return json.load(f)


version_manager = ModelVersionManager()
