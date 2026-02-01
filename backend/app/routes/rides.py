from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import SessionLocal
from app.schemas.ride import RideCreateRequest, RideResponse, ActiveRideResponse
from app.services import ride_service

router = APIRouter(prefix="/api/rides", tags=["Rides"])

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("", response_model=RideResponse, status_code=status.HTTP_201_CREATED)
def create_ride(ride_request: RideCreateRequest, db: Session = Depends(get_db)):
    return ride_service.create_ride(db, ride_request)

@router.get("/active", response_model=ActiveRideResponse)
def get_active_ride(driver_id: UUID, db: Session = Depends(get_db)):
    ride = ride_service.get_active_ride(db, driver_id)
    if not ride:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active ride found for this driver"
        )
    return ride
