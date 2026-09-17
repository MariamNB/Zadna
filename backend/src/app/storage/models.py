"""Storage location models."""

import uuid
from datetime import datetime, timezone
from typing import Optional, List

from sqlalchemy import DateTime, ForeignKey, String, Integer, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.common.base_model import Base, TimestampMixin, UUIDMixin


class StorageLocation(Base, UUIDMixin, TimestampMixin):
    """Storage location model with hierarchical support."""

    __tablename__ = "storage_locations"

    household_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("households.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    parent_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("storage_locations.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    type: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
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
    household: Mapped["Household"] = relationship(back_populates="storage_locations")
    parent: Mapped[Optional["StorageLocation"]] = relationship(
        remote_side="StorageLocation.id",
        back_populates="children",
    )
    children: Mapped[List["StorageLocation"]] = relationship(
        back_populates="parent",
        cascade="all, delete-orphan",
    )
    inventory_items: Mapped[List["InventoryItem"]] = relationship(
        back_populates="storage_location",
        cascade="all, delete-orphan",
    )
    created_by_member: Mapped["HouseholdMember"] = relationship(
        foreign_keys=[created_by],
    )
    updated_by_member: Mapped["HouseholdMember"] = relationship(
        foreign_keys=[updated_by],
    )