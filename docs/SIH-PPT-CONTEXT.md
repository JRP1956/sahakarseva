# SIH 2026 — PS 26089 · Project Context for the PPT

**Problem Statement:** Cooperative Gig Services Platform for Household & Community Services
**Organization:** Ministry of Cooperation · National Council for Cooperative Training (NCCT)
**Theme:** Agriculture, FoodTech & Rural Development · **Category:** Software
**Idea submission deadline:** 30 September 2026

Working name for the product: **SahakarSeva** (सहकार सेवा — "cooperative service"). Change it if the team prefers something else.

---

## 1. The problem (in one slide)

- Labour Cooperative Federations and Societies across India have a huge pool of skilled workers — electricians, plumbers, carpenters, painters, cleaners, caregivers, drivers, gardeners, technicians.
- They have **no digital platform** to connect these workers to households and institutions that need them.
- Private gig platforms (Urban Company, etc.) dominate the market, take large commissions, and treat workers as contractors with no welfare.
- Result: cooperative workers stay **underutilised** despite having skills, verification, and local presence.

**One-liner:** Skilled cooperative workers exist; the demand exists; the bridge doesn't.

---

## 2. Our solution (in one slide)

A **cooperative-owned digital marketplace** where:

- Customers book verified household/community services from their local Labour Cooperative Society.
- Workers get **fair wages** (transparent split, shown before they accept), **fair distribution of work**, and **visible welfare** (insurance, accident cover, membership).
- The Federation gets an **admin dashboard** with live operations plus **AI demand forecasting** that tells them where to deploy more workers tomorrow.

**Three interfaces, one backend:**

| Interface | Who | Form |
|---|---|---|
| Customer app | Households, institutions | Flutter mobile (Android/iOS) |
| Worker app | Cooperative workers | Same Flutter app, worker role |
| Federation admin | Federation / society officers | Next.js web dashboard |

---

## 3. What makes it different (USP slide)

Private platforms optimise for the customer and the platform. We optimise for **customer + worker + cooperative**.

1. **Transparent wage split** — every booking shows `customer price → worker wage (80%) → cooperative contribution (20%)`. No hidden commission. Worker sees "Estimated earnings ₹480" before accepting.
2. **Fair-workload matching** — the matching algorithm doesn't just pick the closest worker. A worker who has had 3 jobs this week is preferred over one who has had 12, all else equal. This is the cooperative principle encoded in software.
3. **Welfare is first-class** — worker profile shows insurance, accident coverage, cooperative membership, certifications. Customers see it; it builds trust. Federation tracks coverage across all workers.
4. **AI that helps the cooperative, not just the customer** — demand forecasting tells the federation "8 additional cleaning workers recommended in Andheri tomorrow." Workforce planning, not surge pricing.
5. **Cooperative-owned** — the platform, the data, and the revenue stay inside the cooperative structure. Federation → Society → Worker hierarchy is built into the data model.
6. **Multilingual & rural-ready** — English, Hindi, Marathi at launch; UI-string localisation via Flutter, designed to add more.

---

## 4. Feature coverage vs. the Problem Statement

Every bullet the PS asks for, and how we cover it:

| PS requirement | Our implementation |
|---|---|
| Service provider registration & verification | Worker registers via app under a Society; society officer verifies certificates in admin |
| Worker skill profiling & certification | Skills tagged per service; certificate upload (ITI, safety training, etc.) with verified badge |
| Customer booking & scheduling | Pick service → location → date/time → matched workers → confirm |
| Geo-location based service matching | PostGIS radius search (10 km) + weighted match score |
| Digital payments & invoicing | Razorpay (UPI/cards/net banking); auto-generated invoice on completion |
| Rating & feedback | 1–5 stars + comment after each job; feeds worker rating |
| Worker welfare & insurance integration | Welfare flags on profile; federation welfare coverage report |
| Emergency / on-demand booking | "Emergency" button → auto-assign top-scored available worker, 1.5× price |
| Cooperative federation admin dashboard | Next.js: stats, demand map, workers, bookings, payments, welfare, forecast |
| Multilingual mobile application | EN / HI / MR via Flutter localisation |
| AI-based demand forecasting & workforce allocation | XGBoost 7-day forecast per service per area; shortage = predicted − available workers → recommendations |

Technology components asked: Mobile Apps ✅ · AI ✅ · Geo-spatial ✅ · Digital Payments ✅ · Cloud ✅ (Railway/AWS).

---

## 5. Architecture (diagram slide)

```
   ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────────┐
   │  Customer App    │   │   Worker App     │   │  Federation Admin    │
   │    (Flutter)     │   │    (Flutter)     │   │     (Next.js)        │
   └────────┬─────────┘   └────────┬─────────┘   └──────────┬───────────┘
            │                      │                        │
            └──────────────────────┼────────────────────────┘
                                   │  HTTPS / JSON (JWT)
                                   ▼
                     ┌──────────────────────────┐
                     │      FastAPI Backend     │
                     │  auth · bookings · match │
                     │  pricing · payments      │
                     │  admin · forecast        │
                     └──────┬──────────┬────────┘
                            │          │
              ┌─────────────┘          └──────────────┐
              ▼                                       ▼
   ┌─────────────────────┐                 ┌─────────────────────┐
   │ PostgreSQL + PostGIS│                 │  AI Module (Python) │
   │ workers, bookings,  │◄────────────────│  XGBoost forecast   │
   │ geo, payments,      │   reads history │  shortage detection │
   │ demand history      │   writes fcst   │                     │
   └─────────────────────┘                 └─────────────────────┘

   External: Razorpay (payments) · Google Maps / OSM (maps) · Railway (hosting)
```

Talking points:
- Single backend, three clients — nothing duplicated.
- Relational data model because the domain is relational (Cooperative → Workers → Skills/Certs/Welfare; Bookings → Worker/Customer/Payment/Invoice/Rating).
- PostGIS handles "find available electricians within 5 km" natively.

---

## 6. Tech stack (slide)

| Layer | Technology | Why |
|---|---|---|
| Mobile (customer + worker) | Flutter | One codebase, Android + iOS, fast UI, built-in localisation |
| Admin dashboard | Next.js + React + TypeScript + Tailwind | Best-in-class for data-heavy admin UIs |
| Backend API | FastAPI (Python) | Fast to build, auto OpenAPI docs, same language as AI |
| Database | PostgreSQL + PostGIS | Relational + geospatial queries |
| Auth | JWT access + refresh tokens | Role-based: customer / worker / admin |
| Payments | Razorpay | UPI, cards, net banking — India-native |
| AI / ML | Python, pandas, XGBoost | Demand forecasting on tabular time-series |
| Maps | Google Maps Platform / OpenStreetMap | Location pick, distance |
| Hosting | Railway (prototype) → AWS (scale) | Quick deploy for SIH |
| Offline cache (mobile) | Hive / SQLite | Worker app usable on poor networks |

Roadmap items (not in prototype): Redis + Celery for background jobs, Firebase Cloud Messaging for push, S3 for file storage.

---

## 7. The matching algorithm (slide — this is a strong technical talking point)

Customer says "I need a plumber at 6 pm in Andheri."

```
Customer location
      ↓
PostGIS: workers within 10 km, has "plumbing" skill, available, not double-booked
      ↓
Score each candidate (0–100):
      35%  Skill match        (has required skill, bonus for related skills)
      25%  Distance           (closer = higher, linear to 10 km)
      15%  Availability       (available now vs later today)
      10%  Rating             (avg stars / 5)
      10%  Experience         (years, capped at 10)
       5%  Fair-workload      (fewer jobs this week = higher)
      ↓
Top 5 shown to customer with score breakdown, distance, rating, welfare badges
(Emergency: auto-assign #1)
```

Why fair-workload matters: two equally qualified workers, A has done 12 jobs this week, B has done 3. A is 200 m closer. A pure distance algorithm always picks A. Ours gives B a fair chance. **That is a cooperative platform, not a gig platform.**

---

## 8. Pricing & fair wages (slide)

```
Customer price  =  service base price  × (1.5 if emergency)
Worker wage     =  80% of customer price
Cooperative     =  20% of customer price  (society operations, welfare fund)
```

- Worker sees estimated earnings **before** accepting.
- Invoice shows the split to the customer too — transparency builds trust.
- Percentages are per-service and configurable by the federation.

Compare: private platforms take 20–35% commission and the worker doesn't see the maths.

---

## 9. AI: demand forecasting & workforce allocation (slide)

**Input:** historical bookings — date, service type, area, day of week, month, weekend flag, 7-day and 14-day lag counts.
**Model:** XGBoost regressor (gradient-boosted trees). Practical, fast to train, explainable — better than forcing an LLM into forecasting.
**Output:** next 7 days, per service, per area.

Example dashboard output:
```
Andheri — tomorrow
Cleaning     ████████████  predicted 20   available 12   ⚠ shortage 8
Electrical   █████████     predicted 12   available 15   ok
Plumbing     ██████        predicted  8   available  9   ok

→ "8 additional cleaning workers recommended in Andheri tomorrow."
```

The federation can act on this: notify idle cleaning workers in nearby Bandra, or run a recruitment drive. **AI serves the cooperative's planning, not surge pricing.**

---

## 10. User journeys (screens to mock up)

### Customer
1. Login (phone + password) → Home: search bar, service categories, **Emergency** button, upcoming bookings
2. Pick service → pick location on map → date/time
3. Match results: 5 worker cards — name, society, ⭐ rating, distance, price, welfare badges (Insured ✓, Coop member ✓)
4. Confirm → Razorpay checkout
5. Booking detail: status timeline (Assigned → Accepted → In progress → Completed → Paid)
6. Rate & review → invoice

### Worker
1. Login → Dashboard: nearby job requests with **Estimated earnings ₹480**, Accept / Decline
2. My bookings: Start job → Complete job
3. Earnings: this month ₹18,420, 34 jobs, per-job list
4. Availability toggle (online / offline)
5. Profile: skills, certifications (upload), welfare card

Worker profile card (good for a slide):
```
┌────────────────────────────┐
│ Ramesh Kumar               │
│ Electrician · Andheri LCS  │
│ ⭐ 4.8  (112 jobs)         │
│ Skills                     │
│ ✓ Residential Wiring       │
│ ✓ Appliance Repair         │
│ Certifications             │
│ ✓ ITI Electrical  ✓ Safety │
│ Welfare                    │
│ ✓ Insurance  ✓ Accident    │
│ ✓ Cooperative Member       │
│ Jobs this month: 34        │
│ Earnings: ₹18,420          │
└────────────────────────────┘
```

### Federation admin
1. Dashboard: tiles (Total workers 1,284 · Active 846 · Today's jobs 392), demand map (booking pins by area), AI forecast panel
2. Workers: list, verify certificates, welfare status
3. Bookings: live table with status, filters
4. Cooperatives: federation → societies tree
5. Payments: settlements per society
6. Welfare: coverage % across workers
7. Forecast: run model, view 7-day table + shortage recommendations

---

## 11. Booking lifecycle (flow slide)

```
Customer books → Match → Customer picks worker → Razorpay payment
      → Worker accepts → Worker starts → Worker completes
      → Invoice generated → Customer rates → Worker rating updated
      → Settlement: 80% worker / 20% society
```
Cancellation allowed until the job starts.

---

## 12. Data model (backup slide / appendix)

```
Cooperative (Federation)
 └── Cooperative (Society)
      ├── Worker ── Skills, Certifications, Welfare flags, Location (geo)
      └── Bookings ── Customer, Worker, Service, Location (geo),
                      Payment, Invoice, Rating
Service ── base price, worker %, coop %
DemandHistory ── date, service, area, count      (feeds AI)
Forecast ── date, service, area, predicted, available, shortage
```

---

## 13. Impact & feasibility (slide)

**Impact**
- Workers: higher utilisation, fair pay, welfare visibility, dignity of cooperative membership.
- Customers: verified, local, insured workers at transparent prices.
- Cooperatives: new revenue stream, data-driven workforce planning, digital presence competing with private platforms.
- Government: strengthens the cooperative movement (aligned with "Sahakar se Samriddhi"), formalises gig labour with welfare.

**Feasibility**
- All components are proven open-source / commodity tech.
- Prototype runs on free tiers (Railway, Razorpay test mode).
- Federation onboarding = upload worker roster CSV + verify certificates.

**Scalability**
- Stateless API → horizontal scaling; PostGIS handles millions of points.
- Add Redis/Celery for background jobs and FCM push at scale.
- New languages = new ARB file; new states = new federation row.

**Risks & mitigation**
| Risk | Mitigation |
|---|---|
| Low digital literacy among workers | Simple UI, local language, society officer can onboard on their behalf |
| Poor connectivity in rural areas | Offline cache in worker app; SMS fallback (roadmap) |
| Trust in payments | Razorpay (RBI-regulated), transparent invoice |
| Cold-start for AI forecasting | Seed with historical society records; model improves with data |

---

## 14. Prototype demo plan (what we'll show)

Seeded with Mumbai data: 1 federation, 5 societies (Andheri, Bandra, Dadar, Thane, Borivali), 8 services, ~40 workers, 60 past bookings, 18 months of demand history.

Demo script (5 min):
1. Customer app: book a plumber in Andheri → see 5 matched workers with scores → pay (test mode).
2. Worker app: see the request with ₹ earnings → accept → complete.
3. Customer: rate → invoice.
4. Admin: watch the booking appear on the map; open Forecast → "8 additional cleaning workers recommended in Andheri tomorrow."

---

## 15. Team & timeline (fill in)

| Phase | Deliverable |
|---|---|
| Week 1 | Backend core: DB, auth, bookings, matching, pricing |
| Week 2 | Flutter customer + worker flows |
| Week 2–3 | Next.js admin dashboard |
| Week 3 | AI forecast + admin panel; Razorpay test; localisation |
| By 30 Sept | Deployed prototype + PPT |

---

## Suggested slide order (SIH template is ~6–8 slides)

1. Title — team, PS ID 26089, product name
2. Problem & our idea (sections 1–2)
3. Solution overview + USP (section 3)
4. Technical approach: architecture + stack (sections 5–6)
5. Key algorithms: matching, fair wages, AI forecasting (sections 7–9)
6. Feasibility, impact, risks (section 13)
7. Prototype screens / demo plan (sections 10, 14)
8. References — PS text, Razorpay docs, PostGIS, XGBoost, Flutter i18n
