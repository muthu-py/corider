from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.services.ml_service import ml_service

router = APIRouter(prefix="/api/ml", tags=["ML"])

class PredictionRequest(BaseModel):
    pickup_lat: float
    pickup_lon: float
    drop_lat: float
    drop_lon: float
    departure_time: Optional[datetime] = None

class PredictionResponse(BaseModel):
    multiplier: float
    message: str

@router.post("/predict-multiplier", response_model=PredictionResponse)
async def predict_multiplier(request: PredictionRequest):
    try:
        multiplier = ml_service.predict_eta_multiplier(
            request.pickup_lat,
            request.pickup_lon,
            request.drop_lat,
            request.drop_lon,
            request.departure_time
        )
        return PredictionResponse(
            multiplier=multiplier,
            message="Prediction successful"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
