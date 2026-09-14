# Backend — Cooperative Gig Services API

```bash
docker compose up -d db            # PostGIS on localhost:5433
cd backend
uv sync
uv run alembic upgrade head
uv run python seed.py              # Mumbai demo data
uv run uvicorn app.main:app --reload --port 8000
uv run pytest                      # tests use the gig_test DB in the same container
```

Docs: http://localhost:8000/docs · Demo logins (password `pass123`): admin `9999999999`, customer `9100000000`, worker `9800000001`.

Forecast: `POST /api/v1/admin/forecast/run` then `GET /api/v1/admin/forecast`.
Payments: Razorpay test keys in `.env`; without keys `POST /payments/demo-mark-paid` marks a booking paid.
