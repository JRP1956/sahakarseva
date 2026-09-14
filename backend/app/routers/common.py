"""Serializers shared by several routers."""
from app.models import Booking, Worker
from app.schemas.bookings import BookingOut, PersonOut, WorkerBrief


def worker_brief(w: Worker) -> WorkerBrief:
    return WorkerBrief(id=w.id, name=w.user.name, coop_name=w.coop.name, rating_avg=w.rating_avg, rating_count=w.rating_count,
                       experience_years=w.experience_years, jobs_this_week=w.jobs_this_week, has_insurance=w.has_insurance,
                       has_accident_cover=w.has_accident_cover, is_coop_member=w.is_coop_member, skills=[s.name for s in w.skills])


def booking_out(b: Booking) -> BookingOut:
    return BookingOut(id=b.id, service_id=b.service_id, service_name=b.service.name, status=b.status, lat=b.lat, lng=b.lng,
                      address=b.address, scheduled_at=b.scheduled_at, is_emergency=b.is_emergency,
                      customer_price=b.customer_price, worker_wage=b.worker_wage, coop_contribution=b.coop_contribution,
                      customer=PersonOut(id=b.customer.id, name=b.customer.user.name, phone=b.customer.user.phone),
                      worker=worker_brief(b.worker) if b.worker else None,
                      razorpay_order_id=b.razorpay_order_id, created_at=b.created_at)
