from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel

from app.models import BookingStatus


class BookingCreate(BaseModel):
    service_id: int
    lat: float
    lng: float
    address: str
    scheduled_at: datetime
    is_emergency: bool = False


class AssignIn(BaseModel):
    worker_id: int


class PersonOut(BaseModel):
    id: int
    name: str
    phone: str


class WorkerBrief(BaseModel):
    id: int
    name: str
    coop_name: str
    rating_avg: float
    rating_count: int
    experience_years: int
    jobs_this_week: int
    has_insurance: bool
    has_accident_cover: bool
    is_coop_member: bool
    skills: list[str]


class CandidateOut(BaseModel):
    worker: WorkerBrief
    distance_km: float
    score: float
    breakdown: dict[str, float]


class BookingOut(BaseModel):
    id: int
    service_id: int
    service_name: str
    status: BookingStatus
    lat: float
    lng: float
    address: str
    scheduled_at: datetime
    is_emergency: bool
    customer_price: Decimal
    worker_wage: Decimal
    coop_contribution: Decimal
    customer: PersonOut
    worker: WorkerBrief | None
    razorpay_order_id: str | None
    created_at: datetime | None
