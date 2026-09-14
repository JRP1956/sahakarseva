from datetime import datetime, timedelta, timezone

from app.models import Cooperative, Service, Skill, User, Worker, WorkerSkill
from app.services.matching import find_candidates, score_worker


def test_perfect_score():
    s, br = score_worker(skill_match=1, distance_km=0, available_now=True, rating_avg=5, experience_years=10, jobs_this_week=0)
    assert s == 100 and br["skill"] == 35


def test_distance_component_zero_at_radius():
    _, br = score_worker(skill_match=1, distance_km=10, available_now=True, rating_avg=5, experience_years=10, jobs_this_week=0)
    assert br["distance"] == 0


def test_fair_workload_prefers_lighter_worker():
    a, _ = score_worker(skill_match=1, distance_km=1.0, available_now=True, rating_avg=4.5, experience_years=5, jobs_this_week=12)
    b, _ = score_worker(skill_match=1, distance_km=1.2, available_now=True, rating_avg=4.5, experience_years=5, jobs_this_week=3)
    assert b > a


def _worker(db, coop, skill, name, lat, lng, jobs=0):
    u = User(phone=f"9{abs(hash(name)) % 10**9:09d}", password_hash="x", role="worker", name=name)
    db.add(u); db.flush()
    w = Worker(user_id=u.id, coop_id=coop.id, location=f"SRID=4326;POINT({lng} {lat})", experience_years=5, rating_avg=4.5, jobs_this_week=jobs)
    db.add(w); db.flush()
    db.add(WorkerSkill(worker_id=w.id, skill_id=skill.id)); db.flush()
    return w


def test_find_candidates_radius_and_ordering(db):
    coop = Cooperative(name="Andheri LCS", area="Andheri"); db.add(coop); db.flush()
    svc = Service(name="Plumbing", category="Home", base_price=500); db.add(svc); db.flush()
    other = Service(name="Painting", category="Home", base_price=800); db.add(other); db.flush()
    sk = Skill(name="Pipe fitting", service_id=svc.id); db.add(sk); db.flush()
    sk2 = Skill(name="Walls", service_id=other.id); db.add(sk2); db.flush()
    near_busy = _worker(db, coop, sk, "near-busy", 19.12, 72.87, jobs=12)      # ~1 km
    near_free = _worker(db, coop, sk, "near-free", 19.125, 72.875, jobs=2)     # ~1.5 km
    far = _worker(db, coop, sk, "far", 19.30, 73.05, jobs=0)                   # ~28 km
    wrong_skill = _worker(db, coop, sk2, "painter", 19.12, 72.87)

    cands = find_candidates(db, svc.id, 19.1136, 72.8697, datetime.now(timezone.utc) + timedelta(hours=2))
    ids = [c.worker.id for c in cands]
    assert far.id not in ids and wrong_skill.id not in ids
    assert ids[0] == near_free.id and ids[1] == near_busy.id
    assert cands[0].distance_km < 10 and "fair_workload" in cands[0].breakdown
