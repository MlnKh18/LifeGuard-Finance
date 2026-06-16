from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    MODEL_VERSION: str = "rule-v1.0.0"
    LOG_LEVEL: str = "info"
    ENVIRONMENT: str = "development"
    ARTIFACTS_DIR: str = "artifacts"
    DATA_DIR: str = "data"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
