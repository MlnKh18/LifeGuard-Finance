import json
import os

from sklearn.model_selection import train_test_split

from src.config.constants import INDICATOR_NAMES, TEST_SIZE, RANDOM_STATE
from src.config.settings import settings
from src.datasets.generator import SyntheticDataGenerator
from src.models.ml_models import FVSModelTrainer
from src.evaluation.evaluator import model_evaluator
from src.utils.versioning import ModelVersionManager


class TrainingPipeline:
    """End-to-end training: generate data → train models → evaluate → persist best."""

    def __init__(self) -> None:
        self.generator = SyntheticDataGenerator()
        self.trainer = FVSModelTrainer()
        self.version_manager = ModelVersionManager()

    def run(self) -> dict:
        print("[1/5] Generating synthetic dataset...")
        df = self.generator.generate()
        print(f"      Dataset shape: {df.shape}")

        data_dir = settings.DATA_DIR
        os.makedirs(data_dir, exist_ok=True)
        df.to_csv(os.path.join(data_dir, "training_data.csv"), index=False)
        print(f"      Saved to {data_dir}/training_data.csv")

        print("[2/5] Training models...")
        cv_results = self.trainer.train(df)

        for name, res in cv_results.items():
            print(f"      {name}: RMSE={res['cv_rmse_mean']:.4f} (±{res['cv_rmse_std']:.4f}), "
                  f"MAE={res['cv_mae_mean']:.4f}, R²={res['cv_r2_mean']:.4f}")

        print(f"\n      Best model: {self.trainer.best_model_name}")

        print("[3/5] Evaluating on test split...")
        X = df[INDICATOR_NAMES].values
        y = df["fvs_score"].values
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=TEST_SIZE, random_state=RANDOM_STATE
        )

        eval_results = []
        for name, model in self.trainer.models.items():
            needs_scaling = name == "linear_regression"
            result = model_evaluator.evaluate(
                model, X_test, y_test, name,
                needs_scaling=needs_scaling,
                scaler=self.trainer.scaler,
            )
            eval_results.append(result)

        comparison = model_evaluator.compare(eval_results)
        print(f"\n      Test evaluation best: {comparison['best_model']}")
        for r in comparison["ranking"]:
            print(f"      {r['model_name']}: MAE={r['mae']:.4f}, RMSE={r['rmse']:.4f}, R²={r['r2']:.4f}")

        print("[4/5] Saving best model artifacts...")
        best_name = self.trainer.best_model_name
        best_model = self.trainer.get_best_model()
        best_metrics = cv_results[best_name]
        version = f"{best_name}-v1.0.0"

        self.version_manager.save_model(
            model=best_model,
            scaler=self.trainer.scaler,
            model_name=best_name,
            version=version,
            metrics={
                "cv_rmse": best_metrics["cv_rmse_mean"],
                "cv_mae": best_metrics["cv_mae_mean"],
                "cv_r2": best_metrics["cv_r2_mean"],
            },
        )

        print("[5/5] Saving evaluation report...")
        report_path = os.path.join(settings.ARTIFACTS_DIR, "evaluation_report.json")
        report = {
            "cv_results": {
                name: {k: v for k, v in res.items() if k != "model"}
                for name, res in cv_results.items()
            },
            "test_evaluation": comparison,
            "feature_importance": self.trainer.get_feature_importance(),
            "best_model": best_name,
            "model_version": version,
        }
        with open(report_path, "w") as f:
            json.dump(report, f, indent=2)

        print(f"\nTraining complete. Model version: {version}")
        print(f"   Artifacts saved to: {settings.ARTIFACTS_DIR}/")

        return report


if __name__ == "__main__":
    pipeline = TrainingPipeline()
    pipeline.run()
