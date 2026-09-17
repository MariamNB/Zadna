"""Reference data models (Category and Unit)."""

from sqlalchemy import String, JSON, Integer, Boolean, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.common.base_model import Base


class Category(Base):
    """Food category model."""

    __tablename__ = "categories"

    key: Mapped[str] = mapped_column(String(50), primary_key=True)
    labels: Mapped[dict] = mapped_column(JSON, nullable=False)  # {"ar": "...", "en": "..."}
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Unit(Base):
    """Measurement unit model."""

    __tablename__ = "units"

    key: Mapped[str] = mapped_column(String(50), primary_key=True)
    labels: Mapped[dict] = mapped_column(JSON, nullable=False)  # {"ar": "...", "en": "..."}
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)