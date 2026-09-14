import shutil
from datetime import datetime, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy import extract, select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.db import get_db
from app.core.security import require_role
from app.models import Booking, BookingStatus as S, Role, Skill, User, Worker, WorkerCertification
from app.routers.common import booking_out
from app.schemas.bookings import BookingOut
from app.schemas.workers import AvailabilityIn, EarningsOut, WorkerMeOut, WorkerPatch

router = APIRouter(prefix="/workers", tags=["workers"])
worker_only = require_role(Role.worker)


def _me(db: Session, user: User) -> Worker:
    w = db.scalar(select(Worker).where(Worker.user_id == user.id))
    if not w:
        raise HTTPException(404, "Worker profile not found")
    return w


def _out(w: Worker) -> WorkerMeOut:
    return WorkerMeOut(id=w.id, name=w.user.name, coop_id=w.coop_id, coop_name=w.coop.name,
                       lat=w.lat, lng=w.lng, is_available=w.is_available,
                       experience_years=w.experience_years, rating_avg=w.rating_avg, rating_count=w.rating_count,
                       jobs_this_week=w.jobs_this_week, has_insurance=w.has_insurance, has_accident_cover=w.has_accident_cover,
                       is_coop_member=w.is_coop_member,
                       skills=[{"id": s.id, "name": s.name, "service": s.service.name} for s in w.skills],
                       certifications=[{"id": c.id, "name": c.name, "verified": c.verified_by is not None, "file": c.file_path}
                                       for c in w.certifications])


@router.get("/me", response_model=WorkerMeOut)
def me(user: User = Depends(worker_only), db: Session = Depends(get_db)):
    return _out(_me(db, user))


@router.patch("/me", response_model=WorkerMeOut)
def patch_me(body: WorkerPatch, user: User = Depends(worker_only), db: Session = Depends(get_db)):
    w = _me(db, user)
    if body.lat is not None and body.lng is not None:
        w.lat, w.lng = body.lat, body.lng
        w.location = f"SRID=4326;POINT({body.lng} {body.lat})"
    if body.experience_years is not None:
        w.experience_years = body.experience_years
    db.commit()
    db.refresh(w)
    return _out(w)


@router.post("/me/availability", response_model=WorkerMeOut)
def availability(body: AvailabilityIn, user: User = Depends(worker_only), db: Session = Depends(get_db)):
    w = _me(db, user)
    w.is_available = body.is_available
    db.commit()
    return _out(w)


@router.put("/me/skills", response_model=WorkerMeOut)
def set_skills(skill_ids: list[int], user: User = Depends(worker_only), db: Session = Depends(get_db)):
    w = _me(db, user)
    w.skills = list(db.scalars(select(Skill).where(Skill.id.in_(skill_ids))))
    db.commit()
    db.refresh(w)
    return _out(w)


@router.post("/me/certifications", response_model=WorkerMeOut, status_code=201)
def add_certification(name: str = Form(), file: UploadFile | None = File(None), user: User = Depends(worker_only), db: Session = Depends(get_db)):
    w = _me(db, user)
    path = None
    if file:
        Path(settings.upload_dir).mkdir(exist_ok=True)
        path = f"{settings.upload_dir}/w{w.id}_{int(datetime.now().timestamp())}_{Path(file.filename or 'cert').name}"
        with open(path, "wb") as f:
            shutil.copyfileobj(file.file, f)
    db.add(WorkerCertification(worker_id=w.id, name=name, file_path=path))
    db.commit()
    db.refresh(w)
    return _out(w)


@router.get("/me/earnings", response_model=EarningsOut)
def earnings(user: User = Depends(worker_only), db: Session = Depends(get_db)):
    w = _me(db, user)
    now = datetime.now(timezone.utc)
    rows = db.scalars(select(Booking).where(Booking.worker_id == w.id, Booking.status.in_([S.paid, S.rated]),
                                            extract("month", Booking.scheduled_at) == now.month,
                                            extract("year", Booking.scheduled_at) == now.year)
                      .order_by(Booking.scheduled_at.desc())).all()
    return EarningsOut(month_total=sum((b.worker_wage for b in rows), start=0), month_jobs=len(rows),
                       jobs=[{"id": b.id, "service": b.service.name, "date": b.scheduled_at, "wage": b.worker_wage} for b in rows])


@router.get("/me/jobs", response_model=list[BookingOut])
def my_job_requests(user: User = Depends(worker_only), db: Session = Depends(get_db)):
    """Bookings assigned to me awaiting acceptance."""
    w = _me(db, user)
    return [booking_out(b) for b in db.scalars(select(Booking).where(Booking.worker_id == w.id, Booking.status == S.assigned)
                                               .order_by(Booking.scheduled_at))]
