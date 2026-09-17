"""FastAPI application factory."""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import init_db, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    await init_db()
    yield
    await close_db()


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="Household Food Inventory API",
        version="1.0.0",
        description="REST API for managing household food inventory",
        lifespan=lifespan,
    )

    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Health endpoint
    @app.get("/health", tags=["Health"])
    async def health_check():
        return {"status": "ok"}

    # Import and include routers
    from app.auth.router import router as auth_router
    from app.households.router import router as households_router
    from app.inventory.router import router as inventory_router
    from app.storage.router import router as storage_router
    from app.reference.router import router as reference_router
    from app.audit.router import router as audit_router

    app.include_router(auth_router, prefix="/api/v1")
    app.include_router(households_router, prefix="/api/v1")
    app.include_router(inventory_router, prefix="/api/v1")
    app.include_router(storage_router, prefix="/api/v1")
    app.include_router(reference_router, prefix="/api/v1")
    app.include_router(audit_router, prefix="/api/v1")

    return app


app = create_app()