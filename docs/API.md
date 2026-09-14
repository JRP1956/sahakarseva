# API reference

Base URL `http://localhost:8000/api/v1`. Interactive docs at `/docs` (Swagger; use **Authorize** with the
`/auth/token` form). All bodies JSON unless noted. Money fields are decimal **strings** (`"500.00"`).
Timestamps are ISO-8601 with timezone. Errors: `{"detail": "..."}` with 400/401/403/404/409.

Auth header: `Authorization: Bearer <access_token>`. Roles: `customer`, `worker`, `admin`.

## Shared shapes

```jsonc
// BookingOut
{ "id": 62, "service_id": 1, "service_name": "Plumbing", "status": "assigned",
  "lat": 19.1136, "lng": 72.8697, "address": "Andheri West, Mumbai",
  "scheduled_at": "2026-09-15T04:30:00Z", "is_emergency": false,
  "customer_price": "500.00", "worker_wage": "400.00", "coop_contribution": "100.00",
  "customer": { "id": 1, "name": "Rahul Gaikwad", "phone": "9100000000" },
  "worker": WorkerBrief | null, "razorpay_order_id": null, "created_at": "…" }

// WorkerBrief
{ "id": 1, "name": "Ganesh Kumar", "coop_name": "Andheri Labour Cooperative Society",
  "rating_avg": 4.6, "rating_count": 74, "experience_years": 11, "jobs_this_week": 1,
  "has_insurance": true, "has_accident_cover": true, "is_coop_member": true, "skills": ["Bathroom Fitting"] }
```

## Health
| | |
|---|---|
| `GET /health` | `{"ok": true}` |

## Auth (`/auth`)
| Endpoint | Role | Body | Response |
|---|---|---|---|
| `POST /register` | – | `{phone, password(≥6), name, role: customer\|worker, lang="en", coop_id?}` — `coop_id` required for workers; `admin` rejected (400); duplicate phone 409 | 201 `TokenOut` |
| `POST /login` | – | `{phone, password}` | `TokenOut {access_token, refresh_token, role, token_type}` |
| `POST /token` | – | OAuth2 form (`username`, `password`) — for Swagger | `TokenOut` |
| `POST /refresh` | – | `{refresh_token}` | `{access_token, role}` |
| `GET /me` | any | – | `{id, phone, name, role, lang}` |

## Services (`/services`)
| Endpoint | Role | Response |
|---|---|---|
| `GET /services` | – | `[{id, name, category, base_price, worker_share_pct, coop_share_pct, skills:[{id,name}]}]` |
| `GET /services/cooperatives` | – | `[{id, name, area}]` societies (non-federation) — for worker registration |

## Workers (`/workers`, role **worker**)
| Endpoint | Body | Response |
|---|---|---|
| `GET /me` | – | `WorkerMeOut {id, name, coop_id, coop_name, lat, lng, is_available, experience_years, rating_avg, rating_count, jobs_this_week, has_insurance, has_accident_cover, is_coop_member, skills:[{id,name,service}], certifications:[{id,name,verified,file}]}` |
| `PATCH /me` | `{lat?, lng?, experience_years?}` (lat+lng together) | `WorkerMeOut` |
| `POST /me/availability` | `{is_available}` | `WorkerMeOut` |
| `PUT /me/skills` | `[skill_id, …]` (replaces) | `WorkerMeOut` |
| `POST /me/certifications` | multipart: `name` (form), `file` (optional) → saved under `UPLOAD_DIR` | 201 `WorkerMeOut` |
| `GET /me/earnings` | – | `{month_total, month_jobs, jobs:[{id, service, date, wage}]}` — paid/rated bookings this calendar month |
| `GET /me/jobs` | – | `[BookingOut]` assigned to me, status `assigned` (awaiting accept) |

## Bookings (`/bookings`)
| Endpoint | Role | Body | Notes |
|---|---|---|---|
| `POST /bookings` | customer | `{service_id, lat, lng, address, scheduled_at, is_emergency=false}` | Prices computed and stored. Emergency → auto-match and assign top candidate (status `assigned`, price ×1.5). 201 `BookingOut` |
| `GET /bookings` | any | – | Customer: own; worker: assigned to me; admin: all. Newest first. |
| `GET /bookings/{id}` | owner/admin | – | `BookingOut` |
| `POST /bookings/{id}/match` | owner/admin | – | `[{worker: WorkerBrief, distance_km, score, breakdown:{skill,distance,availability,rating,experience,fair_workload}}]` top 5 |
| `POST /bookings/{id}/assign` | customer/admin | `{worker_id}` | requested → assigned |
| `POST /bookings/{id}/accept` | worker (own) | – | assigned → accepted |
| `POST /bookings/{id}/start` | worker (own) | – | accepted → in_progress |
| `POST /bookings/{id}/complete` | worker (own) | – | in_progress → completed; creates invoice, `jobs_this_week += 1` |
| `POST /bookings/{id}/cancel` | customer/admin | – | allowed from requested/assigned/accepted |

Invalid transitions → **409** `Cannot go from X to Y`; wrong actor → **403**.

## Payments (`/payments`)
| Endpoint | Role | Body | Response |
|---|---|---|---|
| `POST /create-order` | customer (own) / admin | `{booking_id}` | `{order_id, key_id, amount(paise), currency}` — real Razorpay order if keys configured, else `order_id: "demo"` |
| `POST /verify` | customer/admin | `{booking_id, razorpay_payment_id, razorpay_signature}` | verifies HMAC via Razorpay SDK → completed → paid. 400 on bad signature / no order |
| `POST /demo-mark-paid` | customer/admin | `{booking_id}` | completed → paid without payment. **404 when `DEMO_MARK_PAID=false`** |

## Ratings & invoices
| Endpoint | Role | Body | Response |
|---|---|---|---|
| `POST /ratings` | customer (own) | `{booking_id, stars 1–5, comment?}` | paid → rated; worker `rating_avg`/`rating_count` updated. 201 `BookingOut`. Rating twice → 409 |
| `GET /invoices/{booking_id}?token=<access>` | owner/admin | – | `text/html` invoice. Exists from `completed` onward (404 before). Token via query for browser links |

## Admin (`/admin`, role **admin** on every route)
| Endpoint | Query | Response |
|---|---|---|
| `GET /stats` | – | `{workers, active_workers, customers, todays_jobs, bookings_by_status:{status:n}, revenue_coop}` |
| `GET /workers` | – | `[WorkerBrief + {phone, coop_id, area, is_available, lat, lng, certifications:[{id,name,verified}]}]` |
| `POST /workers/{id}/certifications/{cert_id}/verify` | – | `{id, verified: true}` |
| `GET /customers` | – | `[{id, name, phone, lang}]` |
| `GET /bookings` | `status?` | `[BookingOut]` newest first, max 500 |
| `GET /cooperatives` | – | tree `[{id, name, area, lat, lng, workers, children:[…]}]` |
| `GET /services` | – | `[{id, name, category, base_price, worker_share_pct, coop_share_pct}]` |
| `GET /payments` | – | `{settlements:[{coop, jobs, worker_wages, coop_contribution}], recent:[{booking_id, service, worker, coop, customer_price, worker_wage, coop_contribution, date}]}` |
| `GET /welfare` | – | `{total, insured, accident_cover, members, per_coop:[{coop, total, insured, accident_cover, members}]}` |
| `GET /demand-map` | `days=30` | `[{lat, lng, service, status, is_emergency}]` bookings created in window |
| `POST /forecast/run` | – | trains + predicts + replaces `forecasts`; `{rows}` |
| `GET /forecast` | – | `{generated_at, rows:[{date, service_id, service, area, predicted, available_workers, shortage}], recommendations:[string]}` |

## Example: full customer flow with curl

```bash
B=http://localhost:8000/api/v1
T=$(curl -s $B/auth/login -H 'content-type: application/json' -d '{"phone":"9100000000","password":"pass123"}' | jq -r .access_token)
H="Authorization: Bearer $T"
BK=$(curl -s $B/bookings -H "$H" -H 'content-type: application/json' \
  -d '{"service_id":1,"lat":19.1136,"lng":72.8697,"address":"Andheri W","scheduled_at":"2026-09-20T10:00:00+05:30"}')
ID=$(echo $BK | jq .id)
curl -s -X POST $B/bookings/$ID/match -H "$H" | jq '.[] | {name: .worker.name, score, distance_km, jobs: .worker.jobs_this_week}'
curl -s -X POST $B/bookings/$ID/assign -H "$H" -H 'content-type: application/json' -d '{"worker_id": 1}' | jq .status
```
