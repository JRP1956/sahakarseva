# SahakarSeva — Cooperative Gig Services Platform

SIH 2026 · PS 26089 · Ministry of Cooperation (NCCT)

A cooperative-owned marketplace connecting households with verified workers from Labour Cooperative Societies — fair wages, fair-workload matching, worker welfare, and AI demand forecasting for the federation.

| Part | Stack | Docs |
|---|---|---|
| `backend/` | FastAPI · PostgreSQL/PostGIS · XGBoost | [backend/README.md](backend/README.md) |
| `admin/` | Next.js federation dashboard | [admin/README.md](admin/README.md) |
| `mobile/` | Flutter customer + worker app | (in progress) |

Design spec: [docs/superpowers/specs](docs/superpowers/specs/2026-09-14-coop-gig-platform-design.md) · PPT brief: [docs/SIH-PPT-CONTEXT.md](docs/SIH-PPT-CONTEXT.md)

## Quick start
```bash
docker compose up -d db
cd backend && uv sync && uv run alembic upgrade head && uv run python seed.py && uv run uvicorn app.main:app --port 8000
cd admin && npm install && npm run dev
```
Admin login `9999999999 / pass123`.
