import pytest
from fastapi import HTTPException

from app.models import Booking, BookingStatus as S, Invoice
from app.services.lifecycle import transition
from tests.helpers import make_world, when


def _booking(db, world, status=S.requested, worker=None):
    b = Booking(customer_id=world["customer"].id, worker_id=worker.id if worker else None, service_id=world["svc"].id,
                lat=19.11, lng=72.87, location="SRID=4326;POINT(72.87 19.11)", address="A", scheduled_at=when(),
                customer_price=500, worker_wage=400, coop_contribution=100, status=status)
    db.add(b); db.flush(); db.refresh(b)
    return b


def test_happy_chain_creates_invoice(db):
    w = make_world(db)
    b = _booking(db, w)
    cust, worker, admin = w["customer"].user, w["worker"].user, w["admin"]
    b.worker_id = w["worker"].id; db.flush(); db.refresh(b)
    for new, actor in [(S.assigned, cust), (S.accepted, worker), (S.in_progress, worker), (S.completed, worker), (S.paid, cust), (S.rated, cust)]:
        transition(db, b, new, actor)
    assert b.status == S.rated
    assert db.query(Invoice).filter_by(booking_id=b.id).one().number == f"INV-{b.id:06d}"
    assert w["worker"].jobs_this_week == 1


def test_skip_state_409(db):
    w = make_world(db)
    b = _booking(db, w)
    with pytest.raises(HTTPException) as e:
        transition(db, b, S.in_progress, w["admin"])
    assert e.value.status_code == 409


def test_customer_cannot_accept(db):
    w = make_world(db)
    b = _booking(db, w, S.assigned, w["worker"])
    with pytest.raises(HTTPException) as e:
        transition(db, b, S.accepted, w["customer"].user)
    assert e.value.status_code == 403
