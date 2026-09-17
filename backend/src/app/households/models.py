"""Household models."""

import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.common.base_model import Base, TimestampMixin, UUIDMixin


class Household(Base, UUIDMixin, TimestampMixin):
    """Household model."""

    __tablename__ = "households"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    timezone: Mapped[str] = mapped_column(String(50), default="UTC", nullable=False)

    # Relationships
    members: Mapped[list["HouseholdMember"]] = relationship(
        back_populates="household",
        cascade="all, delete-orphan",
    )
    inventory_items: Mapped[list["InventoryItem"]] = relationship(
        back_populates="household",
        cascade="all, delete-orphan",
    )
    storage_locations: Mapped[list["StorageLocation"]] = relationship(
        back_populates="household",
        cascade="all, delete-orphan",
    )
    audit_logs: Mapped[list["AuditLog"]] = relationship(
        back_populates="household",
        cascade="all, delete-orphan",
    )


class HouseholdMember(Base, UUIDMixin, TimestampMixin):
    """Household membership model."""

    __tablename__ = "household_members"

    household_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("households.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    role: Mapped[str] = mapped_column(
        String(20),
        default="member",
        nullable=False,
    )
    joined_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    household: Mapped["Household"] = relationship(back_populates="members")
    user: Mapped["User"] = relationship(back_populates="household_members")
    created_inventory_items: Mapped[list["InventoryItem"]] = relationship(
        back_populates="created_by_member",
        foreign_keys="InventoryItem.created_by",
    )
    updated_inventory_items: Mapped[list["InventoryItem"]] = relationship(
        back_populates="updated_by_member",
        foreign_keys="InventoryItem.updated_by",
    )
    created_storage_locations: Mapped[list["StorageLocation"]] = relationship(
        back_populates="created_by_member",
        foreign_keys="StorageLocation.created_by",
    )
    updated_storage_locations: Mapped[list["StorageLocation"]] = relationship(
        back_populates="updated_by_member",
        foreign_keys="StorageLocation.updated_by",
    )
    audit_logs: Mapped[list["AuditLog"]] = relationship(
        back_populates="actor",
        foreign_keys="AuditLog.actor_user_id",
    )

    __table_args__ = (
        UniqueConstraint("household_id", "user_id", name="uq_household_member"),
    )