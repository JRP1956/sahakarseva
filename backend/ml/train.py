"""CLI: train on demand_history in the DB and save ml/model.json."""
import pandas as pd

from app.core.db import engine
from ml.forecast import train

if __name__ == "__main__":
    df = pd.read_sql("select date, service_id, area, count from demand_history", engine)
    model = train(df)
    model.save_model("ml/model.json")
    print(f"trained on {len(df)} rows -> ml/model.json")
