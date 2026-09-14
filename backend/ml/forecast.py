"""Demand forecasting: XGBoost on daily (service, area) booking counts."""
from datetime import date, timedelta

import pandas as pd
from xgboost import XGBRegressor

FEATURES = ["service_id", "area_code", "dow", "month", "is_weekend", "lag_7", "lag_14"]


def _area_codes(df: pd.DataFrame) -> dict[str, int]:
    return {a: i for i, a in enumerate(sorted(df["area"].unique()))}


def build_features(df: pd.DataFrame) -> pd.DataFrame:
    """df: columns date, service_id, area, count. Adds calendar + lag features; drops rows without lags."""
    df = df.sort_values(["service_id", "area", "date"]).copy()
    df["date"] = pd.to_datetime(df["date"])
    codes = _area_codes(df)
    df["area_code"] = df["area"].map(codes)
    df["dow"] = df["date"].dt.dayofweek
    df["month"] = df["date"].dt.month
    df["is_weekend"] = (df["dow"] >= 5).astype(int)
    g = df.groupby(["service_id", "area"])["count"]
    df["lag_7"] = g.shift(7)
    df["lag_14"] = g.shift(14)
    return df.dropna(subset=["lag_7", "lag_14"])


def train(history: pd.DataFrame) -> XGBRegressor:
    feat = build_features(history)
    model = XGBRegressor(n_estimators=200, max_depth=4, learning_rate=0.1, objective="reg:squarederror")
    model.fit(feat[FEATURES], feat["count"])
    return model


def predict_next_7(model: XGBRegressor, history: pd.DataFrame, start: date | None = None) -> pd.DataFrame:
    """Recursive 7-day forecast per (service, area). Returns date, service_id, area, predicted."""
    hist = history.copy()
    hist["date"] = pd.to_datetime(hist["date"])
    codes = _area_codes(hist)
    start = start or (hist["date"].max().date() + timedelta(days=1))
    rows = []
    for (sid, area), grp in hist.groupby(["service_id", "area"]):
        series = grp.set_index("date")["count"].to_dict()
        for i in range(7):
            d = pd.Timestamp(start + timedelta(days=i))
            lag7 = series.get(d - timedelta(days=7), 0)
            lag14 = series.get(d - timedelta(days=14), 0)
            x = pd.DataFrame([{"service_id": sid, "area_code": codes[area], "dow": d.dayofweek, "month": d.month,
                               "is_weekend": int(d.dayofweek >= 5), "lag_7": lag7, "lag_14": lag14}])
            pred = max(float(model.predict(x[FEATURES])[0]), 0.0)
            series[d] = pred
            rows.append({"date": d.date(), "service_id": int(sid), "area": area, "predicted": round(pred, 1)})
    return pd.DataFrame(rows)
