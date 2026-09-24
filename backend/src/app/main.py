"""FastAPI application factory."""

from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.common.exceptions import (
    AppException,
    AuthorizationError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
    ValidationError,
)
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

    # Exception handlers
    @app.exception_handler(AppException)
    async def app_exception_handler(request: Request, exc: AppException):
        print(f"AppException caught: {type(exc).__name__}: {exc.message}")
        status_code = 500
        if isinstance(exc, NotFoundError):
            status_code = 404
        elif isinstance(exc, ValidationError):
            status_code = 422
        elif isinstance(exc, AuthorizationError):
            status_code = 401
        elif isinstance(exc, ConflictError):
            status_code = 409
        elif isinstance(exc, ForbiddenError):
            status_code = 403
        
        return JSONResponse(
            status_code=status_code,
            content={"detail": exc.message, "code": exc.code, "details": exc.details},
        )

    # Catch-all exception handler for unhandled exceptions
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        import traceback
        print(f"General Exception caught: {type(exc).__name__}: {exc}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"detail": "Internal server error", "code": "INTERNAL_ERROR", "details": str(exc)},
        )

    # CORS middleware — wildcard origin + credentials=True is forbidden by spec
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
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