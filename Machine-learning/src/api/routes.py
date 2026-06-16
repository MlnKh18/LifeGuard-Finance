from fastapi import APIRouter, HTTPException

from src.schemas.fvs import (
    FvsCalculateRequest,
    FvsCalculateResponse,
    ModelVersionResponse,
    HealthResponse,
    ErrorResponse,
)
from src.inference.predictor import fvs_predictor
from src.utils.versioning import version_manager

router = APIRouter()


@router.post(
    "/fvs/calculate",
    response_model=FvsCalculateResponse,
    responses={
        422: {"model": ErrorResponse, "description": "Validation Error"},
        500: {"model": ErrorResponse, "description": "Internal Server Error"},
    },
)
async def calculate_fvs(request: FvsCalculateRequest) -> FvsCalculateResponse:
    try:
        result = fvs_predictor.predict(request)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/model/version", response_model=ModelVersionResponse)
async def get_model_version() -> ModelVersionResponse:
    metadata = version_manager.get_metadata()

    if metadata:
        return ModelVersionResponse(
            modelVersion=metadata.get("model_version", "rule-v1.0.0"),
            modelType=metadata.get("model_type", "rule_based"),
            trainedAt=metadata.get("trained_at"),
            datasetVersion=metadata.get("dataset_version"),
            metrics=metadata.get("metrics"),
        )

    return ModelVersionResponse(
        modelVersion="rule-v1.0.0",
        modelType="rule_based",
    )


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    return HealthResponse(
        status="healthy",
        service="fvs-ml-service",
        version=fvs_predictor.model_version,
    )
