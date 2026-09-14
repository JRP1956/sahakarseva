import pandas as pd
from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.models import Cooperative, DemandHistory, Forecast, Skill, Worker, WorkerSkill
from ml.forecast import predict_next_7, train


def shortage(predicted: float, available: int) -> int:
    return max(round(predicted) - available, 0)


def available_workers_by(db: Session) -> dict[tuple[int, str], int]:
    """(service_id, area) -> count of available workers in that area with a skill for that service."""
    rows = db.execute(
        select(Skill.service_id, Cooperative.area, func.count(func.distinct(Worker.id)))
        .join(WorkerSkill, WorkerSkill.skill_id == Skill.id)
        .join(Worker, Worker.id == WorkerSkill.worker_id)
        .join(Cooperative, Cooperative.id == Worker.coop_id)
        .where(Worker.is_available.is_(True))
        .group_by(Skill.service_id, Cooperative.area)
    ).all()
    return {(sid, area): n for sid, area, n in rows}


def run_forecast(db: Session) -> list[Forecast]:
    hist = pd.read_sql(select(DemandHistory.date, DemandHistory.service_id, DemandHistory.area, DemandHistory.count), db.connection())
    if hist.empty:
        return []
    preds = predict_next_7(train(hist), hist)
    avail = available_workers_by(db)
    db.execute(delete(Forecast))
    out = []
    for r in preds.itertuples():
        a = avail.get((r.service_id, r.area), 0)
        out.append(Forecast(date=r.date, service_id=r.service_id, area=r.area, predicted=r.predicted,
                            available_workers=a, shortage=shortage(r.predicted, a)))
    db.add_all(out)
    db.flush()
    return out
