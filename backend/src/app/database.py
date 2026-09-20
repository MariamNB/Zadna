"""Database engine and session management."""

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings
from app.common.base_model import Base

# Import all models to register them with Base.metadata
from app.auth import models as auth_models  # noqa: F401
from app.households import models as household_models  # noqa: F401
from app.storage import models as storage_models  # noqa: F401
from app.inventory import models as inventory_models  # noqa: F401
from app.reference import models as reference_models  # noqa: F401
from app.audit import models as audit_models  # noqa: F401

engine = create_async_engine(
    settings.DATABASE_URL.replace("postgresql+asyncpg", "postgresql+psycopg"),
    echo=False,
    pool_pre_ping=True,
)

async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db() -> AsyncSession:
    """Dependency for getting database session."""
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def init_db() -> None:
    """Initialize database tables."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def close_db() -> None:
    """Close database connections."""
    await engine.dispose()