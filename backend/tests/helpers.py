"""Shared fixture builders for API tests."""
from datetime import datetime, timedelta, timezone

from app.core.security import hash_password
from app.models import Cooperative, Customer, Role, Service, Skill, User, Worker, WorkerSkill

PW = hash_password("pass123")


def make_world(db):
    coop = Cooperative(name="Andheri LCS", area="Andheri"); db.add(coop); db.flush()
    svc = Service(name="Plumbing", category="Home", base_price=500); db.add(svc); db.flush()
    sk = Skill(name="Pipe fitting", service_id=svc.id); db.add(sk); db.flush()
    cu = User(phone="9100000001", password_hash=PW, role=Role.customer, name="Asha"); db.add(cu); db.flush()
    cust = Customer(user_id=cu.id); db.add(cust); db.flush()
    wu = User(phone="9100000002", password_hash=PW, role=Role.worker, name="Ramesh"); db.add(wu); db.flush()
    w = Worker(user_id=wu.id, coop_id=coop.id, location="SRID=4326;POINT(72.87 19.12)", lat=19.12, lng=72.87, experience_years=6, rating_avg=4.5); db.add(w); db.flush()
    db.add(WorkerSkill(worker_id=w.id, skill_id=sk.id))
    au = User(phone="9999999999", password_hash=PW, role=Role.admin, name="Admin"); db.add(au); db.flush()
    return dict(coop=coop, svc=svc, skill=sk, customer=cust, worker=w, admin=au)


def login(client, phone):
    r = client.post("/api/v1/auth/login", json={"phone": phone, "password": "pass123"})
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


def when():
    return (datetime.now(timezone.utc) + timedelta(hours=3)).isoformat()
