from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.db import get_db
from app.core.security import get_current_user
from app.models import Booking, BookingStatus as S, User
from app.routers.common import booking_out
from app.schemas.bookings import BookingOut
from app.services.lifecycle import transition

router = APIRouter(prefix="/payments", tags=["payments"])


class OrderIn(BaseModel):
    booking_id: int


class OrderOut(BaseModel):
    order_id: str
    key_id: str
    amount: int  # paise
    currency: str = "INR"


class VerifyIn(BaseModel):
    booking_id: int
    razorpay_payment_id: str
    razorpay_signature: str


def _client():
    import razorpay
    return razorpay.Client(auth=(settings.razorpay_key_id, settings.razorpay_key_secret))


def _booking(db: Session, booking_id: int, user: User) -> Booking:
    b = db.get(Booking, booking_id)
    if not b:
        raise HTTPException(404, "Booking not found")
    if user.role.value == "customer" and b.customer.user_id != user.id:
        raise HTTPException(403, "Not your booking")
    return b


@router.post("/create-order", response_model=OrderOut)
def create_order(body: OrderIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = _booking(db, body.booking_id, user)
    amount = int(b.customer_price * 100)
    if not settings.razorpay_key_id:
        return OrderOut(order_id="demo", key_id="demo", amount=amount)
    order = _client().order.create({"amount": amount, "currency": "INR", "receipt": f"bk{b.id}"})
    b.razorpay_order_id = order["id"]
    db.commit()
    return OrderOut(order_id=order["id"], key_id=settings.razorpay_key_id, amount=amount)


@router.post("/verify", response_model=BookingOut)
def verify(body: VerifyIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = _booking(db, body.booking_id, user)
    if not b.razorpay_order_id:
        raise HTTPException(400, "No order for this booking")
    try:
        _client().utility.verify_payment_signature({"razorpay_order_id": b.razorpay_order_id,
                                                    "razorpay_payment_id": body.razorpay_payment_id,
                                                    "razorpay_signature": body.razorpay_signature})
    except Exception:
        raise HTTPException(400, "Signature verification failed")
    transition(db, b, S.paid, user)
    db.commit()
    return booking_out(b)


@router.post("/demo-mark-paid", response_model=BookingOut)
def demo_mark_paid(body: OrderIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not settings.demo_mark_paid:
        raise HTTPException(404, "Not found")
    b = transition(db, _booking(db, body.booking_id, user), S.paid, user)
    db.commit()
    return booking_out(b)
