import uuid
from sqlalchemy import Column, String, Integer, Float, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class Ride(Base):
    __tablename__ = "rides"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    driver_id = Column(UUID(as_uuid=True), nullable=False)

    source_name = Column(String, nullable=False)
    source_lat = Column(Float, nullable=False)
    source_lon = Column(Float, nullable=False)

    destination_name = Column(String, nullable=False)
    destination_lat = Column(Float, nullable=False)
    destination_lon = Column(Float, nullable=False)

    departure_time = Column(DateTime, nullable=False)

    available_seats = Column(Integer, nullable=False)

    status = Column(String, nullable=False, default="ACTIVE")

    created_at = Column(DateTime, server_default=func.now())
