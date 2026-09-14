# backend/CLAUDE.md

FastAPI 0.115 · SQLAlchemy 2 · GeoAlchemy2 · Alembic · PostgreSQL 16 + PostGIS 3.4 · pandas + XGBoost · pytest.
Python 3.12 managed by **uv** (`uv sync`, `uv run …`). Read the root `CLAUDE.md` first.

## Run

```bash
docker compose -f ../docker-compose.yml up -d db     # PostGIS on localhost:5433 (db `gig`, test db `gig_test`)
uv sync
uv run alembic upgrade head
uv run python seed.py                                  # idempotent: skips if an admin user exists
uv run uvicorn app.main:app --reload --port 8000       # docs at /docs
uv run pytest -q                                       # 22 tests, ~5 s
```

## Layout and responsibilities

```
app/main.py               create_app(): CORS *, includes every router under /api/v1, GET /health
app/core/config.py        pydantic-settings; env or .env; DATABASE_URL, TEST_DATABASE_URL, JWT_SECRET,
                          RAZORPAY_KEY_ID/SECRET, DEMO_MARK_PAID (bool), UPLOAD_DIR
app/core/db.py            engine, SessionLocal, Base, get_db()
app/core/security.py      bcrypt hashing, HS256 JWT (access 15 min / refresh 30 d), get_current_user, require_role(*roles)
app/models/__init__.py    ALL ORM models in one file (they are small and tightly coupled — keep it that way)
app/schemas/              pydantic in/out models per domain (auth, bookings, workers)
app/services/pricing.py   price_booking(service, is_emergency) -> Price(customer_price, worker_wage, coop_contribution)
app/services/matching.py  score_worker(...) pure; find_candidates(db, service_id, lat, lng, scheduled_at, limit=5)
app/services/lifecycle.py transition(db, booking, new_status, actor) — THE only place status changes; render_invoice()
app/services/forecast.py  run_forecast(db), shortage(predicted, available), available_workers_by(db)
app/routers/common.py     booking_out(), worker_brief() — shared serialisers, use them, don't hand-roll dicts
app/routers/*.py          auth, services (+ public /services/cooperatives), workers, bookings, payments, ratings,
                          invoices, admin (router-level require_role(admin))
ml/forecast.py            build_features(), train(), predict_next_7() — pure pandas/xgboost, no DB
ml/train.py               CLI: trains on demand_history and writes ml/model.json (not used by the API; the API retrains
                          on every /admin/forecast/run because it takes 0.5 s on the seed data)
seed.py                   Mumbai demo data (see below)
alembic/versions/         0001_init (all tables + postgis ext), 0002_worker_latlng
tests/                    conftest (schema per session, rollback per test, TestClient with get_db override),
                          helpers.make_world()/login()/when(), one test file per concern
```

## Conventions

- Routers: thin. Load → authorise → call service → `db.commit()` → serialise via `routers/common.py`.
- Errors: `HTTPException` with 400 (bad input), 401 (auth), 403 (wrong role/owner), 404, 409 (invalid state transition).
- Enums are `str, enum.Enum` stored as `Enum(native_enum=False)` VARCHAR — no Postgres enum types, so adding a
  value is a code change only.
- Geography: write `location="SRID=4326;POINT(lng lat)"` **and** `lat`, `lng`. Query with
  `func.ST_DWithin(col, point, metres)` / `func.ST_Distance` on `Geography` casts (metres, not degrees).
- Auth in tests: `login(client, phone)` returns the header dict. Seeded password for everyone is `pass123`.
- Every new endpoint gets a test hitting it through `TestClient` — the fixtures make that cheap.

## Booking state machine (memorise)

```
requested ──assign──▶ assigned ──accept──▶ accepted ──start──▶ in_progress ──complete──▶ completed ──pay──▶ paid ──rate──▶ rated
    │                    │                    │
    └────────────── cancel (customer/admin) ──┘            (no cancel after in_progress)
```
Actor rules: worker may only accept/start/complete their own booking; customer may assign/cancel/pay/rate their own;
admin may do anything. `completed` creates the `Invoice` row and increments `worker.jobs_this_week`.
`rated` (via `POST /ratings`) updates `rating_avg` incrementally: `(avg*n + stars)/(n+1)`.

## Matching (memorise)

Candidates: workers with a skill whose `service_id` matches, `is_available`, within **10 km** (`ST_DWithin`), and
no accepted/in_progress booking within ±2 h of `scheduled_at`. Score 0–100:

| factor | weight | value |
|---|---|---|
| skill | 35 | 1.0 + 0.1 per extra matching skill, capped 1.0 (so effectively 35 for everyone who qualifies) |
| distance | 25 | `1 − min(km/10, 1)` |
| availability | 15 | 1.0 if available (always true for candidates; kept for future "available later today" = 0.5) |
| rating | 10 | `rating_avg / 5` |
| experience | 10 | `min(years/10, 1)` |
| fair_workload | 5 | `1 − min(jobs_this_week/15, 1)` |

Emergency bookings auto-assign the top candidate at creation. Returned `breakdown` is shown as bars in the app.

## Pricing

`customer_price = base_price × (1.5 if emergency)`, `worker_wage = customer_price × worker_share_pct/100`
(80 by default), `coop_contribution = customer_price − worker_wage`. All `Decimal`, quantised to 0.01,
sum invariant tested.

## Forecast pipeline

`demand_history(date, service_id, area, count)` → `build_features` adds `area_code, dow, month, is_weekend,
lag_7, lag_14` → `XGBRegressor(n_estimators=200, max_depth=4)` → recursive 7-day `predict_next_7` per (service, area)
→ `available_workers_by` counts available workers per (service, area via worker.coop.area) → `shortage` →
`forecasts` table replaced wholesale (`DELETE` then insert). Admin GET builds recommendation strings
`"{shortage} additional {service} workers recommended in {area} on {Day dd Mon}"`.

## Seed data — calibration matters

`seed.py` (`random.seed(42)`, idempotent) creates: 1 federation + 5 societies (Andheri, Bandra, Dadar, Thane,
Borivali with real coords), 8 services with 2–3 skills each, **12 workers per society** (primary service weighted
3:3:4:2:1:1:2:2 toward Plumbing/Electrical/Cleaning), 10 customers, 60 bookings across statuses, 540 days of
`demand_history` with weekend ×1.4, monsoon ×1.4 for plumbing/electrical, summer ×1.3 for cleaning/appliance.

Base daily demand per area is deliberately low (`Plumbing 1.5 … Cleaning 2.2`) so that roughly **a third** of
forecast cells show a shortage of 1–3 workers. Raising it makes every cell red and kills the story. Worker skill
distribution is weighted so the Andheri plumbing match returns 3–4 candidates with different `jobs_this_week`,
which is what makes the fair-workload ranking visible in the demo.

Reseed from scratch:
```bash
docker compose -f ../docker-compose.yml exec -T db psql -U gig -d gig -q -c \
 "TRUNCATE cooperatives, users, services, skills, worker_skills, workers, worker_certifications, customers, bookings, ratings, invoices, demand_history, forecasts RESTART IDENTITY CASCADE;"
uv run python seed.py
```

Seed accounts (password `pass123`): admin `9999999999`; customers `9100000000`–`9100000009`;
workers `9800000001`–`9800000060` (first 12 are Andheri).

## Migrations

`uv run alembic revision --autogenerate -m "…"` then **open the file**: GeoAlchemy2 auto-creates GIST indexes on
`Geography` columns, and autogenerate also emits `op.create_index(..., postgresql_using='gist')` for them —
delete those lines or `upgrade` fails with DuplicateTable. `0001_init` starts with
`op.execute("CREATE EXTENSION IF NOT EXISTS postgis")`.

## Tests

- `conftest.py` drops/creates the schema on `gig_test` once per session, wraps each test in a transaction that is
  rolled back, and overrides `get_db`. Because the same Session is reused across requests within a test, an
  endpoint that `flush()`es before raising leaves rows visible to later requests — validate before writing.
- `helpers.make_world(db)` builds coop + Plumbing service/skill + one customer (9100000001) + one worker Ramesh
  (9100000002, at 19.12/72.87) + admin (9999999999).
- Add tests next to the concern they cover; don't create fixtures files beyond `helpers.py`.
