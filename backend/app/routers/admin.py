from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.security import require_role
from app.models import (Booking, BookingStatus as S, Cooperative, Customer, Forecast, Role, Service, User, Worker,
                        WorkerCertification)
from app.routers.common import booking_out, worker_brief
from app.schemas.bookings import BookingOut
from app.services.forecast import run_forecast

router = APIRouter(prefix="/admin", tags=["admin"], dependencies=[Depends(require_role(Role.admin))])


@router.get("/stats")
def stats(db: Session = Depends(get_db)):
    today = datetime.now(timezone.utc).date()
    by_status = dict(db.execute(select(Booking.status, func.count()).group_by(Booking.status)).all())
    return {
        "workers": db.scalar(select(func.count(Worker.id))),
        "active_workers": db.scalar(select(func.count(Worker.id)).where(Worker.is_available.is_(True))),
        "customers": db.scalar(select(func.count(Customer.id))),
        "todays_jobs": db.scalar(select(func.count(Booking.id)).where(func.date(Booking.scheduled_at) == today)),
        "bookings_by_status": {k.value: v for k, v in by_status.items()},
        "revenue_coop": float(db.scalar(select(func.coalesce(func.sum(Booking.coop_contribution), 0)).where(Booking.status.in_([S.paid, S.rated]))))
    }


@router.get("/workers")
def workers(db: Session = Depends(get_db)):
    return [{**worker_brief(w).model_dump(), "phone": w.user.phone, "coop_id": w.coop_id, "area": w.coop.area,
             "is_available": w.is_available, "lat": w.lat, "lng": w.lng,
             "certifications": [{"id": c.id, "name": c.name, "verified": c.verified_by is not None} for c in w.certifications]}
            for w in db.scalars(select(Worker).order_by(Worker.id))]


@router.post("/workers/{worker_id}/certifications/{cert_id}/verify")
def verify_cert(worker_id: int, cert_id: int, admin: User = Depends(require_role(Role.admin)), db: Session = Depends(get_db)):
    c = db.get(WorkerCertification, cert_id)
    if not c or c.worker_id != worker_id:
        raise HTTPException(404, "Certification not found")
    c.verified_by = admin.id
    db.commit()
    return {"id": c.id, "verified": True}


@router.get("/customers")
def customers(db: Session = Depends(get_db)):
    return [{"id": c.id, "name": c.user.name, "phone": c.user.phone, "lang": c.user.lang} for c in db.scalars(select(Customer))]


@router.get("/bookings", response_model=list[BookingOut])
def bookings(status: S | None = None, db: Session = Depends(get_db)):
    q = select(Booking).order_by(Booking.scheduled_at.desc()).limit(500)
    if status:
        q = q.where(Booking.status == status)
    return [booking_out(b) for b in db.scalars(q)]


@router.get("/cooperatives")
def cooperatives(db: Session = Depends(get_db)):
    counts = dict(db.execute(select(Worker.coop_id, func.count()).group_by(Worker.coop_id)).all())

    def node(c: Cooperative):
        return {"id": c.id, "name": c.name, "area": c.area, "lat": c.lat, "lng": c.lng, "workers": counts.get(c.id, 0),
                "children": [node(ch) for ch in c.children]}
    return [node(c) for c in db.scalars(select(Cooperative).where(Cooperative.parent_id.is_(None)))]


@router.get("/services")
def services(db: Session = Depends(get_db)):
    return [{"id": s.id, "name": s.name, "category": s.category, "base_price": s.base_price,
             "worker_share_pct": s.worker_share_pct, "coop_share_pct": s.coop_share_pct} for s in db.scalars(select(Service))]


@router.get("/payments")
def payments(db: Session = Depends(get_db)):
    rows = db.scalars(select(Booking).where(Booking.status.in_([S.paid, S.rated])).order_by(Booking.scheduled_at.desc())).all()
    per_coop: dict[str, dict] = {}
    for b in rows:
        p = per_coop.setdefault(b.worker.coop.name, {"coop": b.worker.coop.name, "jobs": 0, "worker_wages": 0.0, "coop_contribution": 0.0})
        p["jobs"] += 1
        p["worker_wages"] += float(b.worker_wage)
        p["coop_contribution"] += float(b.coop_contribution)
    return {"settlements": list(per_coop.values()),
            "recent": [{"booking_id": b.id, "service": b.service.name, "worker": b.worker.user.name, "coop": b.worker.coop.name,
                        "customer_price": b.customer_price, "worker_wage": b.worker_wage, "coop_contribution": b.coop_contribution,
                        "date": b.scheduled_at} for b in rows[:50]]}


@router.get("/welfare")
def welfare(db: Session = Depends(get_db)):
    ws = db.scalars(select(Worker)).all()
    per_coop: dict[str, dict] = {}
    for w in ws:
        p = per_coop.setdefault(w.coop.name, {"coop": w.coop.name, "total": 0, "insured": 0, "accident_cover": 0, "members": 0})
        p["total"] += 1
        p["insured"] += w.has_insurance
        p["accident_cover"] += w.has_accident_cover
        p["members"] += w.is_coop_member
    return {"total": len(ws), "insured": sum(w.has_insurance for w in ws), "accident_cover": sum(w.has_accident_cover for w in ws),
            "members": sum(w.is_coop_member for w in ws), "per_coop": list(per_coop.values())}


@router.get("/demand-map")
def demand_map(days: int = 30, db: Session = Depends(get_db)):
    since = datetime.now(timezone.utc) - timedelta(days=days)
    return [{"lat": b.lat, "lng": b.lng, "service": b.service.name, "status": b.status.value, "is_emergency": b.is_emergency}
            for b in db.scalars(select(Booking).where(Booking.created_at >= since))]


@router.post("/forecast/run")
def forecast_run(db: Session = Depends(get_db)):
    rows = run_forecast(db)
    db.commit()
    return {"rows": len(rows)}


@router.get("/forecast")
def forecast(db: Session = Depends(get_db)):
    rows = db.scalars(select(Forecast).order_by(Forecast.date, Forecast.area, Forecast.service_id)).all()
    recs = [f"{r.shortage} additional {r.service.name.lower()} workers recommended in {r.area} on {r.date:%a %d %b}"
            for r in rows if r.shortage > 0]
    return {"generated_at": rows[0].generated_at if rows else None,
            "rows": [{"date": r.date, "service_id": r.service_id, "service": r.service.name, "area": r.area,
                      "predicted": r.predicted, "available_workers": r.available_workers, "shortage": r.shortage} for r in rows],
            "recommendations": recs}
