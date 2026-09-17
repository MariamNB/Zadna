"""Storage location schemas."""

import uuid
from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class StorageLocationBase(BaseModel):
    """Base storage location schema."""

    name: str = Field(min_length=1, max_length=100)
    type: str = Field(pattern="^(fridge|freezer|pantry|garage_freezer|drawer|shelf|section|other)$")
    parent_id: Optional[uuid.UUID] = None
    sort_order: int = 0


class StorageLocationCreate(StorageLocationBase):
    """Storage location creation schema."""

    pass


class StorageLocationUpdate(BaseModel):
    """Storage location update schema."""

    name: Optional[str] = Field(default=None, min_length=1, max_length=100)
    type: Optional[str] = Field(default=None, pattern="^(fridge|freezer|pantry|garage_freezer|drawer|shelf|section|other)$")
    parent_id: Optional[uuid.UUID] = None
    sort_order: Optional[int] = None


class StorageLocationResponse(StorageLocationBase):
    """Storage location response schema."""

    id: uuid.UUID
    household_id: uuid.UUID
    created_by: uuid.UUID
    updated_by: uuid.UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class StorageLocationListResponse(BaseModel):
    """Storage location list response with pagination."""

    items: List[StorageLocationResponse]
    next_page_token: Optional[str] = None