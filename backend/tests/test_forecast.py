from datetime import date, timedelta

import pandas as pd

from app.models import DemandHistory
from app.services.forecast import run_forecast, shortage
from ml.forecast import predict_next_7, train
from tests.helpers import make_world


def test_shortage_math():
    assert shortage(20.4, 12) == 8
    assert shortage(8, 9) == 0
    assert shortage(19.6, 12) == 8


def _history(service_id, area, days=120):
    start = date.today() - timedelta(days=days)
    return [{"date": start + timedelta(days=i), "service_id": service_id, "area": area,
             "count": 10 + (5 if (start + timedelta(days=i)).weekday() >= 5 else 0)} for i in range(days)]


def test_model_learns_weekend_bump():
    df = pd.DataFrame(_history(1, "Andheri"))
    preds = predict_next_7(train(df), df)
    assert len(preds) == 7
    wk = preds[pd.to_datetime(preds["date"]).dt.dayofweek < 5]["predicted"].mean()
    we = preds[pd.to_datetime(preds["date"]).dt.dayofweek >= 5]["predicted"].mean()
    assert we > wk


def test_run_forecast_writes_rows_with_availability(db):
    w = make_world(db)
    db.add_all(DemandHistory(**r) for r in _history(w["svc"].id, "Andheri"))
    db.flush()
    rows = run_forecast(db)
    assert len(rows) == 7
    assert rows[0].available_workers == 1  # Ramesh, available, has plumbing skill, in Andheri
    assert rows[0].shortage == max(round(rows[0].predicted) - 1, 0)
