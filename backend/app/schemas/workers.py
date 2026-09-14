from decimal import Decimal

from pydantic import BaseModel


class WorkerMeOut(BaseModel):
    id: int
    name: str
    coop_id: int
    coop_name: str
    lat: float | None
    lng: float | None
    is_available: bool
    experience_years: int
    rating_avg: float
    rating_count: int
    jobs_this_week: int
    has_insurance: bool
    has_accident_cover: bool
    is_coop_member: bool
    skills: list[dict]
    certifications: list[dict]


class WorkerPatch(BaseModel):
    lat: float | None = None
    lng: float | None = None
    experience_years: int | None = None


class AvailabilityIn(BaseModel):
    is_available: bool


class EarningsOut(BaseModel):
    month_total: Decimal
    month_jobs: int
    jobs: list[dict]


class ServiceOut(BaseModel):
    id: int
    name: str
    category: str
    base_price: Decimal
    worker_share_pct: int
    coop_share_pct: int
    skills: list[dict]
