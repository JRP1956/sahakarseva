from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import HTMLResponse
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.security import decode_token
from app.models import Booking, Invoice, Role, User

router = APIRouter(prefix="/invoices", tags=["invoices"])


@router.get("/{booking_id}", response_class=HTMLResponse)
def invoice(booking_id: int, token: str | None = None, db: Session = Depends(get_db)):
    # browser navigations can't set a Bearer header, so the invoice also accepts ?token=
    if not token:
        raise HTTPException(401, "token required")
    user = db.get(User, int(decode_token(token, "access")["sub"]))
    if not user:
        raise HTTPException(401, "User not found")
    inv = db.scalar(select(Invoice).where(Invoice.booking_id == booking_id))
    if not inv:
        raise HTTPException(404, "No invoice yet")
    b = db.get(Booking, booking_id)
    if user.role != Role.admin and b.customer.user_id != user.id and (not b.worker or b.worker.user_id != user.id):
        raise HTTPException(403, "Not your invoice")
    return inv.html
