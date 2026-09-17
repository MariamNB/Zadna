"""Inventory schemas."""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Optional, List

from pydantic import BaseModel, Field, ConfigDict


class LocalizedLabel(BaseModel):
    """Localized label with key and labels."""

    key: str
    labels: dict[str, str]  # {"ar": "...", "en": "..."}


class InventoryItemBase(BaseModel):
    """Base inventory item schema."""

    name: str = Field(min_length=1, max_length=255)
    category_key: str
    quantity: Decimal = Field(gt=0)
    unit_key: str
    storage_location_id: uuid.UUID
    prepared_at: Optional[date] = None
    frozen_at: Optional[date] = None
    opened_at: Optional[date] = None
    expires_at: Optional[date] = None
    is_homemade: bool = False
    status: str = Field(default="stored", pattern="^(stored|thawing|consumed|discarded)$")
    date_added: Optional[date] = None
    notes: Optional[str] = Field(default=None, max_length=500)


class InventoryItemCreate(InventoryItemBase):
    """Inventory item creation schema."""

    pass


class InventoryItemUpdate(BaseModel):
    """Inventory item update schema (all fields optional)."""

    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    category_key: Optional[str] = None
    quantity: Optional[Decimal] = Field(default=None, gt=0)
    unit_key: Optional[str] = None
    storage_location_id: Optional[uuid.UUID] = None
    prepared_at: Optional[date] = None
    frozen_at: Optional[date] = None
    opened_at: Optional[date] = None
    expires_at: Optional[date] = None
    is_homemade: Optional[bool] = None
    status: Optional[str] = Field(default=None, pattern="^(stored|thawing|consumed|discarded)$")
    date_added: Optional[date] = None
    notes: Optional[str] = Field(default=None, max_length=500)


class InventoryItemResponse(InventoryItemBase):
    """Inventory item response schema."""

    id: uuid.UUID
    household_id: uuid.UUID
    category: LocalizedLabel
    unit: LocalizedLabel
    storage_location: "StorageLocationResponse"  # Forward reference
    date_added: date
    created_by: uuid.UUID
    updated_by: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class InventoryItemListResponse(BaseModel):
    """Inventory item list response with pagination."""

    items: List[InventoryItemResponse]
    next_page_token: Optional[str] = None


# Import StorageLocationResponse to resolve forward reference
from app.storage.schemas import StorageLocationResponse
InventoryItemResponse.model_rebuild()