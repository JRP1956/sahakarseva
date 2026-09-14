from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import auth, bookings, invoices, payments, ratings, services, workers


def create_app() -> FastAPI:
    app = FastAPI(title="Cooperative Gig Services API", docs_url="/docs")
    app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

    @app.get("/api/v1/health")
    def health():
        return {"ok": True}

    for r in (auth, services, workers, bookings, payments, ratings, invoices):
        app.include_router(r.router, prefix="/api/v1")
    return app


app = create_app()
