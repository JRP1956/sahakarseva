# SahakarSeva — Cooperative Gig Services Platform

SIH 2026 · PS 26089 · Ministry of Cooperation (NCCT)

A cooperative-owned marketplace connecting households with verified workers from Labour Cooperative Societies — fair wages, fair-workload matching, worker welfare, and AI demand forecasting for the federation.

| Part | Stack | Docs |
|---|---|---|
| `backend/` | FastAPI · PostgreSQL/PostGIS · XGBoost | [backend/README.md](backend/README.md) |
| `admin/` | Next.js federation dashboard | [admin/README.md](admin/README.md) |
| `mobile/` | Flutter customer + worker app (EN/HI/MR) | [mobile/README.md](mobile/README.md) |

## Documentation

| Doc | What it covers |
|---|---|
| [CLAUDE.md](CLAUDE.md) / [AGENTS.md](AGENTS.md) | Agent guidance: rules, repo map, gotchas, where to change what |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design, data model, pricing, matching, state machine, forecasting, auth |
| [docs/API.md](docs/API.md) | Every endpoint with shapes and a curl walkthrough |
| [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) | Setup, running, testing, common tasks, troubleshooting |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Railway/Vercel, env vars, APK, Razorpay |
| [docs/DEMO-SCRIPT.md](docs/DEMO-SCRIPT.md) | 5-minute judge demo with seed accounts |
| [docs/SIH-PPT-CONTEXT.md](docs/SIH-PPT-CONTEXT.md) | Presentation brief |
| [docs/superpowers/specs](docs/superpowers/specs/2026-09-14-coop-gig-platform-design.md) | Approved design spec (source of truth) |
| `backend/`, `admin/`, `mobile/` `CLAUDE.md` | Per-subproject agent guidance |

## Quick start
```bash
docker compose up -d db
cd backend && uv sync && uv run alembic upgrade head && uv run python seed.py && uv run uvicorn app.main:app --port 8000
cd admin && npm install && npm run dev
```
Admin login `9999999999 / pass123`.
