# CLAUDE.md — agent guidance for SahakarSeva

This file is read by Claude Code (and mirrored as `AGENTS.md` for other agents) at the start of every session.
Read it fully before touching code. Per-subproject files add specifics: `backend/CLAUDE.md`, `admin/CLAUDE.md`, `mobile/CLAUDE.md`.

## What this project is

**SahakarSeva** — Smart India Hackathon 2026, Problem Statement **SIH26089** (Ministry of Cooperation / NCCT):
*"Cooperative Gig Services Platform for Household & Community Services."*

A cooperative-owned marketplace where households book verified workers from Labour Cooperative Societies.
Differentiators vs. private gig platforms: **transparent wage split (80/20)**, **fair-workload matching**,
**visible worker welfare**, and **AI demand forecasting for the federation** — not surge pricing.

It is a **demo prototype for idea submission (deadline 30 Sept 2026)**, not a production system. Optimise for:
1. the demo script working end-to-end (see `docs/DEMO-SCRIPT.md`),
2. screenshots that tell the cooperative story,
3. small, readable code a hackathon team can extend.

Do **not** optimise for scale, multi-tenancy, or security hardening beyond what the spec lists.

## Repository map

```
gig-work/
├── CLAUDE.md (AGENTS.md is a symlink) ← you are here
├── README.md                      quick start
├── docker-compose.yml             PostGIS on host port 5433 (5432 is taken by a local Postgres on the dev Mac)
├── .claude/launch.json            `admin` dev-server config for the Claude browser pane
├── backend/                       FastAPI + SQLAlchemy 2 + PostGIS + XGBoost   → backend/CLAUDE.md
├── admin/                         Next.js 16 federation dashboard             → admin/CLAUDE.md
├── mobile/                        Flutter customer + worker app (EN/HI/MR)    → mobile/CLAUDE.md
└── docs/
    ├── ARCHITECTURE.md            system design, data model, algorithms, state machine
    ├── API.md                     every endpoint with request/response shapes
    ├── DEVELOPMENT.md             setup, running, testing, common tasks, troubleshooting
    ├── DEPLOYMENT.md              Railway/AWS, env vars, Razorpay, APK build
    ├── DEMO-SCRIPT.md             the 5-minute judge demo, with seed accounts
    ├── SIH-PPT-CONTEXT.md         narrative brief for the presentation
    └── superpowers/
        ├── specs/2026-09-14-coop-gig-platform-design.md   the approved design spec (source of truth)
        (implementation plans were removed after execution; the git log has them)
```

## Golden rules for agents

1. **The spec is the source of truth.** `docs/superpowers/specs/2026-09-14-coop-gig-platform-design.md` defines
   scope, formulas, and what is deliberately deferred. If a request conflicts with the spec, say so before building.
2. **Ponytail mode is on** (see the session hook): laziest solution that works. No new abstractions, no new
   dependencies for things stdlib/framework already do, no scaffolding "for later". Fewest files, shortest diff.
3. **Business logic lives in `backend/app/services/`** as pure functions taking a `Session`. Routers are thin.
   Never duplicate pricing/matching/lifecycle logic in a client — clients display what the API returns.
4. **Every state change goes through `transition()`** (`backend/app/services/lifecycle.py`). Do not set
   `booking.status` directly anywhere else, including the seed script (the seed sets initial statuses only).
5. **Money is `Decimal` on the backend, string in JSON, parsed on clients.** Never float arithmetic for prices.
6. **Geography columns are the query index; `lat`/`lng` float columns are for display.** Write both when
   creating/moving a worker or booking. (We avoided the `shapely` dependency this way.)
7. **Tests must pass before claiming done:** `cd backend && uv run pytest -q` (22 tests, ~5 s, needs the Docker DB).
   Flutter: `flutter analyze` must be clean. Admin: `npx next build` must succeed.
8. **Verify in the browser** for UI work — the Claude browser pane at phone width (390×844) for Flutter web,
   desktop for admin. Screenshots have caught every UI bug so far (overflow, non-repainting lists, dark-mode CSS).
9. **Commit per task with a conventional-commit message**, end with the `Co-Authored-By` line the harness gives you.
   Push only when asked. `main` is the integration branch; there is no CI yet.
10. **Do not "improve" seed data casually.** Its numbers are calibrated so the demo tells the story
    (fair-workload ranking visible, ~1/3 of forecast cells showing a shortage). See `backend/CLAUDE.md`.

## Non-obvious facts you will otherwise rediscover the hard way

| Fact | Why it matters |
|---|---|
| PostGIS container is on **host port 5433** | A native Postgres owns 5432 on the dev Mac; `config.py` defaults already point to 5433. |
| `docker compose exec db …` needs `-f ../docker-compose.yml` from `backend/` | compose file is at repo root. |
| XGBoost on macOS needs `brew install libomp` | Otherwise `import xgboost` dies with `libomp.dylib not found`. Linux wheels bundle it. |
| Flutter l10n output is `package:mobile/l10n/app_localizations.dart` | Newer Flutter no longer emits the synthetic `flutter_gen` package. Regenerate with `flutter gen-l10n`. |
| Next.js 16: `src/proxy.ts` exporting `proxy()` replaces `middleware.ts` | Also `cookies()` / `searchParams` are async. |
| Flutter `setState(() => x = future())` throws at runtime | Arrow returns the Future. Use `setState(() { x = future(); })`. Fixed everywhere once; don't reintroduce. |
| Admin `theme.css` and mobile `theme_tokens.g.dart` are generated from `tokens/*.json` | Edit the tokens, rerun `node scripts/build_tokens.mjs --out admin/src/app/theme.css` (then rename `--space-N.5` to `--space-N-5`) and `python3 mobile/tool/build_tokens.py`. Never hand-edit the outputs. |
| Invoice endpoint accepts `?token=` | Browser navigations can't set a Bearer header; the Flutter "View invoice" button uses this. |
| Razorpay SDK is **not** in the Flutter app | No web support. Backend `POST /payments/verify` is ready; `demo-mark-paid` is the demo path (gated by `DEMO_MARK_PAID`). |
| Forecast start date = day after the last `demand_history` row | Seed writes history up to yesterday, so forecasts start today. |
| `available_workers` in forecasts = count of *available* workers with a skill for that service in that area | Not capacity. Shortage = `max(round(predicted) − available, 0)`. |

## Where to make a change

| I want to… | Touch |
|---|---|
| change the match score weights / radius | `backend/app/services/matching.py` (`WEIGHTS`, `RADIUS_M`) + `tests/test_matching.py` + PPT §7 |
| change wage split or emergency multiplier | per-service `worker_share_pct` in DB / seed; `EMERGENCY_MULTIPLIER` in `services/pricing.py` |
| add a booking state or transition | `services/lifecycle.py` (`ALLOWED`, `WORKER_ACTIONS`, `CUSTOMER_ACTIONS`), `BookingStatus` enum, `kStatuses` + `statusTone()` in `mobile/lib/widgets.dart`, `STATUS_TONE` map in `admin/src/components/ui.tsx` |
| add an endpoint | new/existing router in `backend/app/routers/`, include in `main.py`, a test in `backend/tests/`, row in `docs/API.md` |
| add a DB column | model in `backend/app/models/__init__.py` → `uv run alembic revision --autogenerate -m "…"` → check the file (remove duplicate GIST index ops on geography columns) → `uv run alembic upgrade head` |
| add a UI string to the app | all three ARB files in `mobile/lib/l10n/` → `flutter gen-l10n` |
| add a language | new `app_xx.arb`, add `Locale('xx')` to `supportedLocales` in `mobile/lib/main.dart`, item in `LangMenu` |
| add an admin page | `admin/src/app/<name>/page.tsx` (server component using `apiFetch`), link in `NAV` in `layout.tsx` |
| change forecast features/model | `backend/ml/forecast.py` (`FEATURES`, `build_features`, `train`) + `tests/test_forecast.py` |
| change a colour, radius, or type size | `tokens/*.json` only (primitive ramps live under the `blue`/`gray` keys so semantic aliases stay valid), then regenerate both outputs and run `python3 scripts/validate_contrast.py` |
| change the demo data | `backend/seed.py` — then truncate & reseed (see `backend/CLAUDE.md`) |

## Design system (non-negotiable for any UI change)

The UI follows `plugin87/ux-ui-agent-skills` v2.10. Only what we run is vendored: `tokens/*.json`, four scripts in
`scripts/`, and `.claude/rules/*`. The full doctrine is in `docs/design-kit-doctrine.md` (paths it mentions such as
`components/` or `taste/` refer to the upstream kit, not this repo); the parts that bite here:

1. **One theme, one source of truth.** `tokens/*.json` -> generated `admin/src/app/theme.css` and `mobile/lib/theme_tokens.g.dart`.
   No hex, px, `Colors.*`, or Tailwind palette classes in screens. Gate: `python3 scripts/lint_hardcodes.py admin/src`.
2. **Zero emoji anywhere**: UI, code, docs, commit messages. Icons are lucide inline SVG (admin) or Material icons (Flutter).
   Gate: `python3 scripts/check_no_emoji.py admin/src docs CLAUDE.md`.
3. **No em-dashes in UI copy**; write two sentences instead. (Docs may keep them.)
4. **Token by intent**: destructive actions use the danger variant (`btn.danger`, `c.actionDestructive`), never primary.
5. **One thing leads** per screen (a `Stat lead`, a display-size figure, or the H1), display >= 2.5x body.
6. **All states**: hover, focus ring, active, disabled, loading (full strength + spinner, never the disabled look), empty (`Empty`), error.
7. **Both modes**: every screen checked in light and dark in the browser pane before commit.
8. **Contrast on the source**: `python3 scripts/validate_contrast.py` must pass after any token change.

Direction: anchor `enterprise` from the kit library, retuned. Admin = compact density; app = spacious density. Same tokens.

## Definition of done for any task

- Backend tests green, `flutter analyze` clean, `next build` passes (whichever you touched).
- Behaviour verified in the running app (browser pane) if it is user-visible.
- Docs updated if you changed an endpoint (`docs/API.md`), a formula (`docs/ARCHITECTURE.md` + PPT brief), or a workflow (`docs/DEVELOPMENT.md`).
- Committed with a clear message. Not pushed unless asked.

## Things that are explicitly out of scope (do not build unless asked)

Redis/Celery, FCM push, S3/Cloudinary, separate customer/worker Flutter apps, real settlement/KYC, refresh-token
rotation (the admin refreshes, it does not rotate), pagination, RBAC beyond the three roles, i18n of DB content (service names), tests for
Flutter/Next (manual smoke only).
