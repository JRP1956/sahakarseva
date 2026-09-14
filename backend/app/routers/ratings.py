from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.security import require_role
from app.models import Booking, BookingStatus as S, Rating, Role, User
from app.routers.common import booking_out
from app.schemas.bookings import BookingOut
from app.services.lifecycle import transition

router = APIRouter(prefix="/ratings", tags=["ratings"])


class RatingIn(BaseModel):
    booking_id: int
    stars: int = Field(ge=1, le=5)
    comment: str | None = None


@router.post("", response_model=BookingOut, status_code=201)
def rate(body: RatingIn, user: User = Depends(require_role(Role.customer)), db: Session = Depends(get_db)):
    b = db.get(Booking, body.booking_id)
    if not b:
        raise HTTPException(404, "Booking not found")
    transition(db, b, S.rated, user)  # validates ownership + state (rating twice -> 409)
    db.add(Rating(booking_id=b.id, stars=body.stars, comment=body.comment))
    db.flush()
    w = b.worker
    avg, n = db.execute(select(func.avg(Rating.stars), func.count()).join(Booking).where(Booking.worker_id == w.id)).one()
    w.rating_avg, w.rating_count = round(float(avg), 2), n
    db.commit()
    return booking_out(b)
