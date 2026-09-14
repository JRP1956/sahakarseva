from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.models import Service, Skill
from app.schemas.workers import ServiceOut

router = APIRouter(prefix="/services", tags=["services"])


@router.get("", response_model=list[ServiceOut])
def list_services(db: Session = Depends(get_db)):
    skills = db.scalars(select(Skill)).all()
    return [ServiceOut(id=s.id, name=s.name, category=s.category, base_price=s.base_price, worker_share_pct=s.worker_share_pct,
                       coop_share_pct=s.coop_share_pct, skills=[{"id": k.id, "name": k.name} for k in skills if k.service_id == s.id])
            for s in db.scalars(select(Service).order_by(Service.id))]
