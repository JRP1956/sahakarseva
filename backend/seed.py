"""Idempotent demo seed: Mumbai federation, 5 societies, 8 services, ~40 workers, 10 customers, 60 bookings, 18 months demand."""
import random
from datetime import date, datetime, timedelta, timezone

from sqlalchemy import select

from app.core.db import SessionLocal
from app.core.security import hash_password
from app.models import (Booking, BookingStatus as S, Cooperative, Customer, DemandHistory, Invoice, Rating, Role, Service,
                        Skill, User, Worker, WorkerCertification, WorkerSkill)
from app.services.lifecycle import render_invoice
from app.services.pricing import price_booking

random.seed(42)
PW = hash_password("pass123")

SOCIETIES = [("Andheri", 19.1136, 72.8697), ("Bandra", 19.0596, 72.8295), ("Dadar", 19.0178, 72.8478),
             ("Thane", 19.2183, 72.9781), ("Borivali", 19.2307, 72.8567)]
SERVICES = {  # name: (category, base_price, skills)
    "Plumbing": ("Home Repair", 500, ["Pipe Fitting", "Leak Repair", "Bathroom Fitting"]),
    "Electrical": ("Home Repair", 600, ["Residential Wiring", "Appliance Wiring", "Safety Inspection"]),
    "Cleaning": ("Household", 400, ["Deep Cleaning", "Kitchen Cleaning", "Sofa & Carpet"]),
    "Carpentry": ("Home Repair", 700, ["Furniture Repair", "Door & Window", "Modular Fitting"]),
    "Painting": ("Home Repair", 800, ["Interior Painting", "Exterior Painting"]),
    "Gardening": ("Outdoor", 350, ["Lawn Care", "Plant Maintenance"]),
    "Caregiving": ("Care", 900, ["Elderly Care", "Patient Care", "Child Care"]),
    "Appliance Repair": ("Home Repair", 650, ["AC Service", "Washing Machine", "Refrigerator"]),
}
FIRST = ["Ramesh", "Suresh", "Mahesh", "Ganesh", "Sunita", "Anita", "Kavita", "Vijay", "Ajay", "Sanjay", "Deepak", "Prakash",
         "Meena", "Rekha", "Sachin", "Rahul", "Nitin", "Amit", "Pooja", "Shweta"]
LAST = ["Kumar", "Patil", "Jadhav", "Shinde", "More", "Pawar", "Kadam", "Gaikwad", "Sawant", "Chavan"]
CERTS = ["ITI Certificate", "Safety Training", "Skill India Certification", "NCCT Training"]


def seed():
    db = SessionLocal()
    if db.scalar(select(User).where(User.role == Role.admin)):
        print("already seeded")
        return
    fed = Cooperative(name="Mumbai Labour Cooperative Federation", area="Mumbai", lat=19.076, lng=72.877)
    db.add(fed); db.flush()
    socs = []
    for name, lat, lng in SOCIETIES:
        c = Cooperative(name=f"{name} Labour Cooperative Society", parent_id=fed.id, area=name, lat=lat, lng=lng)
        db.add(c); socs.append(c)
    db.flush()

    services, skills = {}, {}
    for name, (cat, price, sk) in SERVICES.items():
        s = Service(name=name, category=cat, base_price=price); db.add(s); db.flush()
        services[name] = s
        skills[name] = []
        for k in sk:
            skill = Skill(name=k, service_id=s.id); db.add(skill); skills[name].append(skill)
    db.flush()

    db.add(User(phone="9999999999", password_hash=PW, role=Role.admin, name="Federation Admin"))

    workers, phone = [], 9800000000
    for soc in socs:
        for _ in range(12):
            phone += 1
            u = User(phone=str(phone), password_hash=PW, role=Role.worker, name=f"{random.choice(FIRST)} {random.choice(LAST)}",
                     lang=random.choice(["en", "hi", "mr"]))
            db.add(u); db.flush()
            lat, lng = soc.lat + random.uniform(-0.02, 0.02), soc.lng + random.uniform(-0.02, 0.02)
            w = Worker(user_id=u.id, coop_id=soc.id, lat=lat, lng=lng, location=f"SRID=4326;POINT({lng} {lat})",
                       is_available=random.random() < 0.85, experience_years=random.randint(1, 15),
                       rating_avg=round(random.uniform(3.5, 5.0), 1), rating_count=random.randint(5, 120),
                       jobs_this_week=random.randint(0, 14), has_insurance=random.random() < 0.8,
                       has_accident_cover=random.random() < 0.7, is_coop_member=True)
            db.add(w); db.flush()
            primary = random.choices(list(SERVICES), weights=[3, 3, 4, 2, 1, 1, 2, 2])[0]
            chosen = set(random.sample(skills[primary], k=random.randint(1, len(skills[primary]))))
            if random.random() < 0.3:
                chosen.add(random.choice(skills[random.choice(list(SERVICES))]))
            for sk in chosen:
                db.add(WorkerSkill(worker_id=w.id, skill_id=sk.id))
            for c in random.sample(CERTS, k=random.randint(1, 2)):
                db.add(WorkerCertification(worker_id=w.id, name=c, verified_by=None))
            w.primary = primary
            workers.append(w)
    db.flush()

    customers = []
    for i in range(10):
        u = User(phone=f"91000000{i:02d}", password_hash=PW, role=Role.customer, name=f"{random.choice(FIRST)} {random.choice(LAST)}")
        db.add(u); db.flush()
        c = Customer(user_id=u.id); db.add(c); customers.append(c)
    db.flush()

    now = datetime.now(timezone.utc)
    for i in range(60):
        w = random.choice(workers)
        svc = services[w.primary]
        soc = w.coop
        emergency = random.random() < 0.1
        p = price_booking(svc, emergency)
        when = now + timedelta(days=random.randint(-28, 3), hours=random.randint(8, 19))
        status = random.choice([S.rated, S.rated, S.paid, S.completed, S.in_progress, S.accepted, S.assigned]) if when < now else random.choice([S.assigned, S.accepted])
        lat, lng = soc.lat + random.uniform(-0.02, 0.02), soc.lng + random.uniform(-0.02, 0.02)
        b = Booking(customer_id=random.choice(customers).id, worker_id=w.id, service_id=svc.id, lat=lat, lng=lng,
                    location=f"SRID=4326;POINT({lng} {lat})", address=f"{random.randint(1, 200)}, {soc.area} West, Mumbai",
                    scheduled_at=when, is_emergency=emergency, status=status, customer_price=p.customer_price,
                    worker_wage=p.worker_wage, coop_contribution=p.coop_contribution, created_at=when - timedelta(days=1))
        db.add(b); db.flush()
        if status in (S.completed, S.paid, S.rated):
            db.add(Invoice(booking_id=b.id, number=f"INV-{b.id:06d}", html=render_invoice(b)))
        if status == S.rated:
            db.add(Rating(booking_id=b.id, stars=random.choice([3, 4, 4, 5, 5, 5]), comment=random.choice(["Great work", "On time", "Good", None])))

    # 18 months of daily demand per (service, area) with weekly seasonality, trend, noise
    base = {"Plumbing": 1.5, "Electrical": 1.5, "Cleaning": 2.2, "Carpentry": 0.9, "Painting": 0.6, "Gardening": 0.6, "Caregiving": 0.9, "Appliance Repair": 1.2}
    start = date.today() - timedelta(days=540)
    rows = []
    for name, svc in services.items():
        for area, *_ in SOCIETIES:
            scale = random.uniform(0.6, 1.6)
            for d in range(540):
                day = start + timedelta(days=d)
                weekend = 1.4 if day.weekday() >= 5 else 1.0
                summer = 1.3 if name in ("Appliance Repair", "Cleaning") and day.month in (4, 5, 6) else 1.0
                monsoon = 1.4 if name in ("Plumbing", "Electrical") and day.month in (7, 8, 9) else 1.0
                mu = base[name] * scale * weekend * summer * monsoon * (1 + d / 1500)
                rows.append(DemandHistory(date=day, service_id=svc.id, area=area, count=max(0, int(random.gauss(mu, mu * 0.35)))))
    db.add_all(rows)
    db.commit()
    print(f"seeded: {len(workers)} workers, {len(customers)} customers, 60 bookings, {len(rows)} demand rows")
    print("admin: 9999999999 / pass123 · customer: 9100000000 / pass123 · worker: 9800000001 / pass123")


if __name__ == "__main__":
    seed()
