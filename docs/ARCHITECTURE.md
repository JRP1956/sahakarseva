# Architecture

SahakarSeva is three clients on one API. This document describes how the pieces fit, the data model, the three
core algorithms (pricing, matching, forecasting), the booking state machine, and the auth model. For the *why*
see the design spec (`superpowers/specs/2026-09-14-coop-gig-platform-design.md`); for endpoint shapes see `API.md`.

## 1. System overview

```
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────────┐
│  Customer role   │   │   Worker role    │   │  Federation Admin    │
│  Flutter (mobile)│   │  Flutter (mobile)│   │  Next.js 16 (admin)  │
└────────┬─────────┘   └────────┬─────────┘   └──────────┬───────────┘
         │  Bearer JWT (access) │                        │ httpOnly cookie → Bearer
         └──────────────────────┼────────────────────────┘
                                ▼  HTTPS · JSON · /api/v1
                  ┌─────────────────────────────┐
                  │        FastAPI (backend)     │
                  │  routers → services → models │
                  └──────┬───────────────┬───────┘
                         │ SQLAlchemy    │ pandas DataFrame
                         ▼               ▼
              ┌────────────────┐   ┌──────────────────┐
              │ PostgreSQL 16  │   │  ml/forecast.py  │
              │ + PostGIS 3.4  │◀──│  XGBoost         │
              └────────────────┘   └──────────────────┘
   External (optional): Razorpay test mode · OpenStreetMap tiles
```

- **One backend process**, stateless apart from the DB. No queue, no cache, no background workers (deferred).
- **The mobile app is a single Flutter codebase**; the role in the JWT decides which home screen renders.
- **The admin dashboard renders server-side** and calls the API with the admin's token from a cookie.
- **ML is a library call**, not a service: `POST /admin/forecast/run` trains and predicts synchronously (~0.5 s on
  seed data) and writes the `forecasts` table.

## 2. Request lifecycle (backend)

```
HTTP → FastAPI router (app/routers/*.py)
     → Depends(get_db) opens a Session
     → Depends(get_current_user / require_role) decodes JWT, loads User, checks role
     → router loads rows, checks ownership (403), calls a service function
     → service (app/services/*.py) applies rules, mutates ORM objects, flush()
     → router commit()s and serialises via routers/common.py
     → pydantic response model → JSON
```
Rules of thumb: routers never contain formulas; services never commit (the router does, so a request is one
transaction); serialisers are shared so every client sees the same `BookingOut` / `WorkerBrief` shape.

## 3. Data model

```
cooperatives ──┬── (parent_id self-ref) federation ▶ societies
               │
               └──▶ workers ──▶ users (role=worker)
                      ├──▶ worker_skills ──▶ skills ──▶ services
                      └──▶ worker_certifications (verified_by → users)
customers ──▶ users (role=customer)
bookings ──▶ customers, workers (nullable until assigned), services
   ├──▶ ratings   (1:1, after paid)
   └──▶ invoices  (1:1, created at completed)
demand_history (date, service_id, area, count)      synthetic 18 months, feeds the model
forecasts      (date, service_id, area, predicted, available_workers, shortage, generated_at)
```

Key columns:

| table | notable columns |
|---|---|
| `users` | `phone` (unique login), `password_hash` (bcrypt), `role` ∈ customer/worker/admin, `lang` |
| `workers` | `location geography(Point,4326)` + `lat`,`lng`; `is_available`; `experience_years`; `rating_avg`,`rating_count`; `jobs_this_week`; welfare flags `has_insurance`,`has_accident_cover`,`is_coop_member` |
| `services` | `base_price numeric(10,2)`, `worker_share_pct` (80), `coop_share_pct` (20), `category` |
| `bookings` | `location`+`lat`,`lng`, `address`, `scheduled_at tz`, `is_emergency`, `status` (varchar enum), `customer_price`,`worker_wage`,`coop_contribution`, `razorpay_order_id`, `created_at` |
| `cooperatives` | `parent_id` (NULL = federation), `area` (used to join workers to forecast cells), `lat`,`lng` |

Geography columns carry GIST indexes (created automatically by GeoAlchemy2). Enums are stored as VARCHAR so new
values need no migration.

## 4. Pricing

```
customer_price    = base_price × (1.5 if is_emergency else 1.0)
worker_wage       = customer_price × worker_share_pct / 100        # 80 % by default
coop_contribution = customer_price − worker_wage                    # 20 %
```
Computed once at booking creation (`services/pricing.py`) and stored on the booking so later changes to a
service's price don't rewrite history. `Decimal`, quantised to paise. The worker sees `worker_wage` as
"Estimated earnings" *before* accepting; the customer sees all three lines on the booking and the invoice.

## 5. Matching

Input: a booking (service, point, scheduled_at). Output: up to 5 candidates with score and breakdown.

**Candidate filter (SQL, PostGIS):**
1. worker has a skill whose `service_id` = booking service
2. `is_available = true`
3. `ST_DWithin(worker.location, booking point, 10 000 m)`
4. no booking in `accepted`/`in_progress` within ±2 h of `scheduled_at`

**Score (Python, `score_worker`), 0–100:**

| factor | weight | formula |
|---|---|---|
| skill match | 35 | `min(1.0 + 0.1·(extra matching skills), 1.0)` |
| distance | 25 | `1 − min(km / 10, 1)` |
| availability | 15 | `1.0` now (0.5 reserved for "later today") |
| rating | 10 | `rating_avg / 5` |
| experience | 10 | `min(years / 10, 1)` |
| fair workload | 5 | `1 − min(jobs_this_week / 15, 1)` |

Why this shape: distance and skill dominate so results are sensible, but the 5-point fair-workload term is enough
to flip the order between two otherwise-similar workers — which is the cooperative story the demo shows
(worker with 1 job at 1.5 km outranks worker with 10 jobs at 0.96 km). Emergency bookings skip the choice and
assign the top candidate automatically.

## 6. Booking state machine

```
requested ─assign─▶ assigned ─accept─▶ accepted ─start─▶ in_progress ─complete─▶ completed ─pay─▶ paid ─rate─▶ rated
    └────────── cancel ──────┴──────── cancel ──────┘
```
Implemented as `ALLOWED: dict[status, set[status]]` in `services/lifecycle.py`; any other move is **409**.
Actor authorisation is in the same function: workers may only accept/start/complete their own bookings,
customers may assign/cancel/pay/rate their own, admins anything. Side effects on transition:

| entering | side effect |
|---|---|
| `assigned` | `worker_id` set by caller first; Razorpay order may be created afterwards |
| `completed` | `Invoice` row (HTML rendered from the booking) + `worker.jobs_this_week += 1` |
| `paid` | via `/payments/verify` (signature checked) or `/payments/demo-mark-paid` (demo flag) |
| `rated` | via `POST /ratings`; `rating_avg = (avg·n + stars)/(n+1)`, `rating_count += 1` |

## 7. Demand forecasting & workforce allocation

```
demand_history ──build_features──▶ [service_id, area_code, dow, month, is_weekend, lag_7, lag_14] ──▶ XGBRegressor
                                                                                                     │
forecast for next 7 days per (service, area), recursive (each day's prediction feeds later lags) ◀────┘
        │
        ▼
available_workers = count(workers where is_available and has skill for service and coop.area = area)
shortage          = max(round(predicted) − available_workers, 0)
        │
        ▼
forecasts table (replaced on each run) → admin: bars per area/day + sentences
"8 additional cleaning workers recommended in Andheri on Tue 15 Sep"
```
Model: 200 trees, depth 4, squared error. Retrained on every run — cheap at this scale and avoids a model
artefact to deploy. `ml/train.py` exists to write `model.json` if you ever want to persist it.

Known simplification: "available workers" is a head-count, not daily capacity. If real data arrives, multiply by
average jobs/worker/day or change `shortage()`.

## 8. Auth

- Register → `users` row + `customers` or `workers` row (workers need `coop_id`). Admins are seeded only.
- Login → `{access_token (15 min), refresh_token (30 d), role}`; HS256 with `JWT_SECRET`.
- Clients send `Authorization: Bearer <access>`. `require_role(...)` yields 403 on mismatch.
- Admin web stores the access token in an httpOnly cookie and re-logs in when it expires (no refresh flow there).
- Invoice HTML additionally accepts `?token=` for plain browser navigation.

## 9. Localisation

UI strings only, via Flutter ARB files (en/hi/mr). DB content (service names, addresses) stays in English —
translating data is out of scope. Language is stored per device (`SharedPreferences`) and sent at registration
(`users.lang`) for future server-side notifications.

## 10. Deliberate omissions

Redis/Celery (no background work exists), FCM (needs Firebase project + signed builds), object storage (files go to
`backend/uploads/`), Razorpay SDK in Flutter (no web support; backend verify endpoint is ready), refresh-token
rotation in admin, pagination, audit logs. Each is listed with the upgrade path in the spec.
