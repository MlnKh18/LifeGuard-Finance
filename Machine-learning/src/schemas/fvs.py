from pydantic import BaseModel, Field
from typing import Optional, Dict, List


class FvsCalculateRequest(BaseModel):
    monthly_income: float = Field(ge=0, description="Monthly income in IDR")
    monthly_expenses: float = Field(ge=0, description="Monthly expenses in IDR")
    total_debt: float = Field(ge=0, description="Total outstanding debt in IDR")
    number_of_dependents: int = Field(ge=0, description="Number of dependents")
    protection_coverage: float = Field(ge=0, description="Total insurance coverage in IDR")
    emergency_fund: float = Field(ge=0, description="Total emergency fund in IDR")


class ExplanationInfo(BaseModel):
    summary: str
    strengths: List[str]
    vulnerabilities: List[str]


class FvsCalculateData(BaseModel):
    score: float
    category: str
    indicators: Dict[str, float]
    feature_importance: Dict[str, float]
    explanation: ExplanationInfo


class FvsCalculateResponse(BaseModel):
    success: bool = True
    model_version: str
    data: FvsCalculateData


class ModelVersionResponse(BaseModel):
    modelVersion: str
    modelType: str
    trainedAt: Optional[str] = None
    datasetVersion: Optional[str] = None
    metrics: Optional[dict] = None


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str


class ErrorResponse(BaseModel):
    detail: str
