from sqlalchemy.orm import Session
from uuid import UUID
from datetime import datetime
from app.models.ride import Ride
from app.schemas.ride import RideCreateRequest, RideResponse, ActiveRideResponse, Location

def create_ride(db: Session, ride_data: RideCreateRequest) -> RideResponse:
    new_ride = Ride(
        driver_id=ride_data.driver_id,
        source_name=ride_data.source.name,
        source_lat=ride_data.source.lat,
        source_lon=ride_data.source.lon,
        destination_name=ride_data.destination.name,
        destination_lat=ride_data.destination.lat,
        destination_lon=ride_data.destination.lon,
        departure_time=ride_data.departure_time,
        available_seats=ride_data.available_seats,
        status="ACTIVE"
    )
    
    db.add(new_ride)
    db.commit()
    db.refresh(new_ride)
    
    return RideResponse(
        ride_id=new_ride.id,
        status=new_ride.status,
        message="Ride created successfully"
    )

def get_active_ride(db: Session, driver_id: UUID) -> ActiveRideResponse | None:
    ride = db.query(Ride).filter(
        Ride.driver_id == driver_id,
        Ride.status == "ACTIVE"
    ).order_by(Ride.created_at.desc()).first()
    
    if not ride:
        return None
        
    return ActiveRideResponse(
        ride_id=ride.id,
        source=Location(
            name=ride.source_name,
            lat=ride.source_lat,
            lon=ride.source_lon
        ),
        destination=Location(
            name=ride.destination_name,
            lat=ride.destination_lat,
            lon=ride.destination_lon
        ),
        departure_time=ride.departure_time,
        available_seats=ride.available_seats,
        status=ride.status
    )
