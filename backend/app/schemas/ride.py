from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field

# Shared Models
class Location(BaseModel):
    name: str = Field(..., min_length=1)
    lat: float = Field(..., ge=-90, le=90)
    lon: float = Field(..., ge=-180, le=180)

# Request Models
class RideCreateRequest(BaseModel):
    driver_id: UUID
    source: Location
    destination: Location
    departure_time: datetime
    available_seats: int = Field(..., gt=0)

# Response Models
class RideResponse(BaseModel):
    ride_id: UUID
    status: str
    message: str

class ActiveRideResponse(BaseModel):
    ride_id: UUID
    source: Location
    destination: Location
    departure_time: datetime
    available_seats: int
    status: str
