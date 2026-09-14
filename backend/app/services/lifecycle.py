from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models import Booking, BookingStatus as S, Invoice, Role, User

ALLOWED: dict[S, set[S]] = {
    S.requested: {S.assigned, S.cancelled},
    S.assigned: {S.accepted, S.cancelled},
    S.accepted: {S.in_progress, S.cancelled},
    S.in_progress: {S.completed},
    S.completed: {S.paid},
    S.paid: {S.rated},
}
WORKER_ACTIONS = {S.accepted, S.in_progress, S.completed}
CUSTOMER_ACTIONS = {S.assigned, S.cancelled, S.paid, S.rated}


def _authorize(db: Session, booking: Booking, new: S, actor: User):
    if actor.role == Role.admin:
        return
    if actor.role == Role.worker:
        if new not in WORKER_ACTIONS or booking.worker is None or booking.worker.user_id != actor.id:
            raise HTTPException(403, "Not your booking / not a worker action")
    else:
        if new not in CUSTOMER_ACTIONS or booking.customer.user_id != actor.id:
            raise HTTPException(403, "Not your booking / not a customer action")


def transition(db: Session, booking: Booking, new: S, actor: User) -> Booking:
    if new not in ALLOWED.get(booking.status, set()):
        raise HTTPException(409, f"Cannot go from {booking.status.value} to {new.value}")
    _authorize(db, booking, new, actor)
    booking.status = new
    if new == S.completed:
        booking.worker.jobs_this_week += 1
        db.add(Invoice(booking_id=booking.id, number=f"INV-{booking.id:06d}", html=render_invoice(booking)))
    db.flush()
    return booking


def render_invoice(b: Booking) -> str:
    return f"""<html><body style="font-family:sans-serif;max-width:480px">
<h2>Invoice INV-{b.id:06d}</h2>
<p><b>Service:</b> {b.service.name}{' (Emergency)' if b.is_emergency else ''}<br>
<b>Worker:</b> {b.worker.user.name} — {b.worker.coop.name}<br>
<b>Customer:</b> {b.customer.user.name}<br>
<b>Address:</b> {b.address}<br>
<b>Scheduled:</b> {b.scheduled_at:%d %b %Y %H:%M}</p>
<table border="1" cellpadding="6" style="border-collapse:collapse">
<tr><td>Customer price</td><td align="right">₹{b.customer_price}</td></tr>
<tr><td>Worker wage ({b.service.worker_share_pct}%)</td><td align="right">₹{b.worker_wage}</td></tr>
<tr><td>Cooperative contribution ({b.service.coop_share_pct}%)</td><td align="right">₹{b.coop_contribution}</td></tr>
</table></body></html>"""
