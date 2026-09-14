from dataclasses import dataclass
from datetime import datetime

from geoalchemy2 import Geography
from sqlalchemy import cast, exists, func, select
from sqlalchemy.orm import Session, selectinload

from app.models import Booking, BookingStatus, Skill, Worker, WorkerSkill

RADIUS_M = 10_000
WEIGHTS = {"skill": 35, "distance": 25, "availability": 15, "rating": 10, "experience": 10, "fair_workload": 5}


@dataclass
class Candidate:
    worker: Worker
    distance_km: float
    score: float
    breakdown: dict[str, float]


def score_worker(*, skill_match: float, distance_km: float, available_now: bool, rating_avg: float,
                 experience_years: int, jobs_this_week: int) -> tuple[float, dict[str, float]]:
    factors = {
        "skill": min(skill_match, 1.0),
        "distance": 1 - min(distance_km / 10, 1.0),
        "availability": 1.0 if available_now else 0.5,
        "rating": rating_avg / 5,
        "experience": min(experience_years / 10, 1.0),
        "fair_workload": 1 - min(jobs_this_week / 15, 1.0),
    }
    breakdown = {k: round(WEIGHTS[k] * v, 2) for k, v in factors.items()}
    return round(sum(breakdown.values()), 2), breakdown


def find_candidates(db: Session, service_id: int, lat: float, lng: float, scheduled_at: datetime, limit: int = 5) -> list[Candidate]:
    point = cast(func.ST_SetSRID(func.ST_MakePoint(lng, lat), 4326), Geography)
    dist = func.ST_Distance(Worker.location, point)
    busy = exists().where(
        Booking.worker_id == Worker.id,
        Booking.status.in_([BookingStatus.accepted, BookingStatus.in_progress]),
        func.abs(func.extract("epoch", Booking.scheduled_at) - func.extract("epoch", func.cast(scheduled_at, Booking.scheduled_at.type))) < 7200,
    )
    q = (select(Worker, dist.label("d"))
         .join(WorkerSkill, WorkerSkill.worker_id == Worker.id)
         .join(Skill, Skill.id == WorkerSkill.skill_id)
         .where(Skill.service_id == service_id, Worker.is_available.is_(True),
                func.ST_DWithin(Worker.location, point, RADIUS_M), ~busy)
         .options(selectinload(Worker.skills).selectinload(Skill.service), selectinload(Worker.user), selectinload(Worker.coop))
         .distinct())
    out = []
    for worker, d in db.execute(q):
        matching = [s for s in worker.skills if s.service_id == service_id]
        skill_match = 1.0 + 0.1 * (len(matching) - 1)
        score, br = score_worker(skill_match=skill_match, distance_km=d / 1000, available_now=worker.is_available,
                                 rating_avg=worker.rating_avg, experience_years=worker.experience_years,
                                 jobs_this_week=worker.jobs_this_week)
        out.append(Candidate(worker=worker, distance_km=round(d / 1000, 2), score=score, breakdown=br))
    out.sort(key=lambda c: c.score, reverse=True)
    return out[:limit]
