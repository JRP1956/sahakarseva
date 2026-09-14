# Cooperative Gig Services Platform — Design Spec

SIH 2026 · PS 26089 · Ministry of Cooperation / NCCT
Goal: working demo prototype for idea submission (deadline 30 Sept 2026).

## Scope

A cooperative-owned services marketplace: customers book verified workers from
Labour Cooperative Societies; the federation gets a dashboard with AI demand
forecasting and workforce-shortage recommendations. Differentiators vs private
platforms: transparent wage split, fair-workload allocation, visible worker
welfare.

**In scope:** auth, worker profiles (skills/certs/welfare), service catalogue,
geo-matching, booking lifecycle, Razorpay test-mode payment, invoice, rating,
emergency booking, admin dashboard, XGBoost demand forecast + shortage
recommendations, EN/HI/MR localization, seed data for a scripted Mumbai demo.

**Out of scope (deferred):** Redis, Celery, FCM push, S3/Cloudinary, two
separate Flutter apps, real financial settlement, KYC, deployment hardening.

## Stack

| Layer | Tech |
|---|---|
| Mobile (customer + worker) | Flutter, Riverpod, Dio, flutter_localizations |
| Admin web | Next.js (App Router, TypeScript), Tailwind, shadcn/ui, Leaflet |
| API | FastAPI, SQLAlchemy 2, Alembic, pydantic |
| DB | PostgreSQL 16 + PostGIS |
| Auth | JWT access (15 min) + refresh (30 d); roles customer/worker/admin |
| Payments | Razorpay test mode |
| AI | pandas + XGBoost |
| Files | local disk under `backend/uploads/` |
| Dev/deploy | Docker Compose (postgis + backend); Railway at the end |

## Repo layout

```
gig-work/
  backend/
    app/            FastAPI app: routers/, models/, schemas/, services/, core/
    ml/             train.py, forecast.py
    alembic/
    seed.py
    tests/
  mobile/           Flutter app, lib/{features,core,l10n}
  admin/            Next.js app
  docker-compose.yml
  docs/superpowers/specs/
```

## Data model

- `cooperatives(id, name, parent_id nullable, area)` — federation → society.
- `users(id, phone unique, password_hash, role, name, lang)`.
- `workers(id, user_id, coop_id, location geography(Point,4326), is_available,
  experience_years, rating_avg, rating_count, jobs_this_week, has_insurance,
  has_accident_cover, is_coop_member)`.
- `skills(id, name, service_id)`; `worker_skills(worker_id, skill_id)`.
- `worker_certifications(id, worker_id, name, file_path, verified_by nullable)`.
- `services(id, name, category, base_price, worker_share_pct, coop_share_pct)`.
- `customers(id, user_id, default_location geography)`.
- `bookings(id, customer_id, worker_id nullable, service_id, location
  geography, address, scheduled_at, is_emergency, status, customer_price,
  worker_wage, coop_contribution, razorpay_order_id nullable, created_at)`.
  `status ∈ requested, assigned, accepted, in_progress, completed, paid,
  rated, cancelled`.
- `ratings(id, booking_id unique, stars, comment)`.
- `invoices(id, booking_id unique, number, html)`.
- `demand_history(date, service_id, area, count)` — synthetic 18 months.
- `forecasts(date, service_id, area, predicted, available_workers, shortage,
  generated_at)`.

## Core logic

### Pricing
```
customer_price   = service.base_price * (1.5 if is_emergency else 1.0)
worker_wage      = customer_price * worker_share_pct   (default 80%)
coop_contribution= customer_price * coop_share_pct     (default 20%)
```
Worker sees `worker_wage` as "Estimated earnings" before accepting.

### Matching (`POST /bookings/{id}/match`)
1. PostGIS: workers within 10 km (`ST_DWithin`), `is_available`, has a skill
   for the booking's service, no overlapping accepted booking at `scheduled_at`.
2. Score per worker (0–100):
   - skill_match 35 — 1.0 if any skill matches service, +bonus per extra skill
     in same category (capped 1.0)
   - distance 25 — `1 - min(dist_km/10, 1)`
   - availability 15 — 1.0 if available now, 0.5 if available later today
   - rating 10 — `rating_avg / 5`
   - experience 10 — `min(experience_years/10, 1)`
   - fair_workload 5 — `1 - min(jobs_this_week/15, 1)`
3. Return top 5 with score breakdown; customer picks one (or auto-assign top 1
   for emergency).

### Booking lifecycle
requested → assigned (customer picks) → accepted (worker) → in_progress →
completed (worker) → paid (Razorpay webhook / test-mode confirm) → rated.
Cancel allowed until in_progress. Transitions enforced in one
`transition(booking, new_status, actor)` function; invalid → 409.

On `completed`: invoice row created; `workers.jobs_this_week` incremented.
On `rated`: `rating_avg` recomputed.

### Payment
On `assigned`, create Razorpay order (test keys). Flutter opens Razorpay
checkout; on success calls `POST /payments/verify` with signature → status
`paid`. Fallback button "Mark paid (demo)" behind an env flag for offline demos.

### Forecast
- `ml/train.py`: features `service_id, area, day_of_week, month, is_weekend,
  lag_7, lag_14`; target `count`; XGBoost regressor; saves `model.json`.
- `ml/forecast.py` / `POST /admin/forecast/run`: predicts next 7 days per
  (service, area); `available_workers` = count of available workers with that
  skill in area; `shortage = max(predicted - available_workers, 0)`; upserts
  `forecasts`.
- Dashboard renders per-area bars and recommendation lines:
  "8 additional cleaning workers recommended in Andheri tomorrow."

## API surface (FastAPI, `/api/v1`)

- `auth`: register, login, refresh, me
- `services`: list
- `workers`: me (GET/PATCH), availability, skills, certifications (upload),
  welfare, earnings summary, nearby jobs
- `bookings`: create, match, assign, accept, start, complete, cancel, list
  (customer / worker), detail
- `payments`: create-order, verify, webhook
- `ratings`: create
- `invoices`: get by booking
- `admin`: stats, workers, customers, bookings, cooperatives, payments,
  welfare, forecast/run, forecast (latest), demand-map (booking points)

OpenAPI docs at `/docs`.

## Mobile app (Flutter)

Login → role from JWT.

Customer: Home (search, categories, emergency button, upcoming/past) →
Service detail → Location + schedule → Match results (top 5 with score,
distance, rating, welfare badges) → Booking detail (status timeline, pay,
rate).

Worker: Dashboard (available jobs nearby with estimated earnings, accept) →
My bookings (start/complete) → Earnings (month total, per-job) →
Availability toggle → Profile (skills, certifications upload, welfare card).

Localization: ARB files en/hi/mr; language picker in settings, stored in
`users.lang`.

## Admin (Next.js)

Pages: Dashboard (tiles: workers, active, today's jobs; demand map;
forecast panel), Workers, Customers, Bookings, Cooperatives, Services,
Payments, Welfare, Forecast (run + table). Data via fetch to FastAPI with
admin JWT in httpOnly cookie.

## Seed data

`backend/seed.py`: 1 federation, 5 societies (Andheri, Bandra, Dadar, Thane,
Borivali), 8 services, ~40 workers with real-looking Mumbai coords, 10
customers, 60 past bookings, 18 months of `demand_history`, 1 admin. Idempotent.

## Testing

pytest + PostGIS test DB (docker):
- `test_pricing.py` — split sums to customer_price; emergency multiplier.
- `test_matching.py` — score weights; fair-workload prefers lighter worker at
  equal skill/distance; out-of-radius excluded.
- `test_lifecycle.py` — valid chain passes; skipping a state → 409.
- `test_forecast.py` — shortage math on a fixed prediction.
Flutter/Next: manual smoke via seed demo script.

## Build order

1. Backend core: compose, models, migrations, auth, CRUD, seed.
2. Pricing + matching + lifecycle (+ tests).
3. Flutter: auth, customer flow, worker flow.
4. Admin: dashboard, tables, map.
5. ML: train, forecast endpoint, admin forecast panel.
6. Polish: localization, Razorpay test, emergency, Railway deploy.
