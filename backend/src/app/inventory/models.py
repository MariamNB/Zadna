"""Inventory item models."""

import uuid
from datetime import date, datetime, timezone
from decimal import Decimal
from typing import Optional, List

from sqlalchemy import Date, DateTime, ForeignKey, String, Text, Numeric, Boolean, CheckConstraint, Enum as SQLEnum, func, UniqueConstraint, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.common.base_model import Base, TimestampMixin, UUIDMixin
from app.common.unicode import normalize_nfc


class InventoryItem(Base, UUIDMixin, TimestampMixin):
    """Inventory item model."""

    __tablename__ = "inventory_items"

    household_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("households.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(Text, nullable=False)
    name_normalized: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    category_key: Mapped[str] = mapped_column(
        String(50),
        ForeignKey("categories.key", ondelete="RESTRICT"),
        nullable=False,
    )
    quantity: Mapped[Decimal] = mapped_column(
        Numeric(10, 3),
        nullable=False,
    )
    unit_key: Mapped[str] = mapped_column(
        String(50),
        ForeignKey("units.key", ondelete="RESTRICT"),
        nullable=False,
    )
    storage_location_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("storage_locations.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    prepared_at: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    frozen_at: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    opened_at: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    expires_at: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    is_homemade: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    status: Mapped[str] = mapped_column(
        String(20),
        default="stored",
        nullable=False,
    )
    date_added: Mapped[date] = mapped_column(
        Date,
        default=lambda: date.today(),
        nullable=False,
    )
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_by: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("household_members.id", ondelete="SET NULL"),
        nullable=False,
    )
    updated_by: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("household_members.id", ondelete="SET NULL"),
        nullable=False,
    )

    # Relationships
    household: Mapped["Household"] = relationship(back_populates="inventory_items")
    category: Mapped["Category"] = relationship()
    unit: Mapped["Unit"] = relationship()
    storage_location: Mapped["StorageLocation"] = relationship(back_populates="inventory_items")
    created_by_member: Mapped["HouseholdMember"] = relationship(
        foreign_keys=[created_by],
    )
    updated_by_member: Mapped["HouseholdMember"] = relationship(
        foreign_keys=[updated_by],
    )

    # Constraints
    __table_args__ = (
        CheckConstraint("quantity > 0", name="ck_inventory_quantity_positive"),
        CheckConstraint("char_length(notes) <= 500", name="ck_inventory_notes_length"),
        CheckConstraint("status IN ('stored','thawing','consumed','discarded')", name="ck_inventory_status"),
        Index("ix_inventory_household_storage", "household_id", "storage_location_id"),
        Index("ix_inventory_household_category", "household_id", "category_key"),
        Index("ix_inventory_household_category_storage", "household_id", "category_key", "storage_location_id"),
        Index("ix_inventory_household_created", "household_id", "created_at"),
    )

    def __init__(self, **kwargs):
        if "name" in kwargs:
            kwargs["name_normalized"] = normalize_nfc(kwargs["name"])
        super().__init__(**kwargs)