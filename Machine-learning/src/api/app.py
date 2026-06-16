from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.routes import router
from src.inference.predictor import fvs_predictor


def create_app() -> FastAPI:
    application = FastAPI(
        title="LifeGuard Finance — FVS ML Service",
        description="Financial Vulnerability Score calculation and prediction service",
        version="1.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    application.include_router(router)

    @application.on_event("startup")
    async def startup_event():
        fvs_predictor.reload()
        model_type = "ML" if fvs_predictor.is_ml_model else "Rule-Based"
        print(f"FVS Predictor loaded: {fvs_predictor.model_version} ({model_type})")

    return application


app = create_app()
