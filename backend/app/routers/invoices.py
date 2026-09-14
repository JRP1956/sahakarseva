from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import HTMLResponse
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.security import get_current_user
from app.models import Booking, Invoice, Role, User

router = APIRouter(prefix="/invoices", tags=["invoices"])


@router.get("/{booking_id}", response_class=HTMLResponse)
def invoice(booking_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    inv = db.scalar(select(Invoice).where(Invoice.booking_id == booking_id))
    if not inv:
        raise HTTPException(404, "No invoice yet")
    b = db.get(Booking, booking_id)
    if user.role != Role.admin and b.customer.user_id != user.id and (not b.worker or b.worker.user_id != user.id):
        raise HTTPException(403, "Not your invoice")
    return inv.html
