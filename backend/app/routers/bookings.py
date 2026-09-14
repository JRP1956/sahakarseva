from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.security import get_current_user, require_role
from app.models import Booking, BookingStatus as S, Customer, Role, Service, User, Worker
from app.routers.common import booking_out, worker_brief
from app.schemas.bookings import AssignIn, BookingCreate, BookingOut, CandidateOut
from app.services.lifecycle import transition
from app.services.matching import find_candidates
from app.services.pricing import price_booking

router = APIRouter(prefix="/bookings", tags=["bookings"])


def _get(db: Session, booking_id: int) -> Booking:
    b = db.get(Booking, booking_id)
    if not b:
        raise HTTPException(404, "Booking not found")
    return b


def _own_or_admin(b: Booking, user: User):
    if user.role == Role.admin:
        return
    if user.role == Role.customer and b.customer.user_id == user.id:
        return
    if user.role == Role.worker and b.worker and b.worker.user_id == user.id:
        return
    raise HTTPException(403, "Not your booking")


@router.post("", response_model=BookingOut, status_code=201)
def create_booking(body: BookingCreate, user: User = Depends(require_role(Role.customer)), db: Session = Depends(get_db)):
    svc = db.get(Service, body.service_id)
    if not svc:
        raise HTTPException(404, "Service not found")
    customer = db.scalar(select(Customer).where(Customer.user_id == user.id))
    p = price_booking(svc, body.is_emergency)
    b = Booking(customer_id=customer.id, service_id=svc.id, lat=body.lat, lng=body.lng,
                location=f"SRID=4326;POINT({body.lng} {body.lat})", address=body.address, scheduled_at=body.scheduled_at,
                is_emergency=body.is_emergency, customer_price=p.customer_price, worker_wage=p.worker_wage,
                coop_contribution=p.coop_contribution)
    db.add(b)
    db.flush()
    if body.is_emergency:
        cands = find_candidates(db, svc.id, body.lat, body.lng, body.scheduled_at, limit=1)
        if cands:
            b.worker_id = cands[0].worker.id
            transition(db, b, S.assigned, user)
    db.commit()
    db.refresh(b)
    return booking_out(b)


@router.get("", response_model=list[BookingOut])
def my_bookings(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    q = select(Booking).order_by(Booking.scheduled_at.desc())
    if user.role == Role.customer:
        q = q.join(Customer).where(Customer.user_id == user.id)
    elif user.role == Role.worker:
        q = q.join(Worker, Booking.worker_id == Worker.id).where(Worker.user_id == user.id)
    return [booking_out(b) for b in db.scalars(q)]


@router.get("/{booking_id}", response_model=BookingOut)
def get_booking(booking_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = _get(db, booking_id)
    _own_or_admin(b, user)
    return booking_out(b)


@router.post("/{booking_id}/match", response_model=list[CandidateOut])
def match(booking_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = _get(db, booking_id)
    _own_or_admin(b, user)
    return [CandidateOut(worker=worker_brief(c.worker), distance_km=c.distance_km, score=c.score, breakdown=c.breakdown)
            for c in find_candidates(db, b.service_id, b.lat, b.lng, b.scheduled_at)]


@router.post("/{booking_id}/assign", response_model=BookingOut)
def assign(booking_id: int, body: AssignIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = _get(db, booking_id)
    if not db.get(Worker, body.worker_id):
        raise HTTPException(404, "Worker not found")
    b.worker_id = body.worker_id
    db.flush()
    db.refresh(b)
    transition(db, b, S.assigned, user)
    db.commit()
    return booking_out(b)


def _simple(new: S):
    def handler(booking_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
        b = transition(db, _get(db, booking_id), new, user)
        db.commit()
        return booking_out(b)
    return handler


router.post("/{booking_id}/accept", response_model=BookingOut)(_simple(S.accepted))
router.post("/{booking_id}/start", response_model=BookingOut)(_simple(S.in_progress))
router.post("/{booking_id}/complete", response_model=BookingOut)(_simple(S.completed))
router.post("/{booking_id}/cancel", response_model=BookingOut)(_simple(S.cancelled))
