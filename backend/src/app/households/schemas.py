"""Household schemas."""

import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class HouseholdResponse(BaseModel):
    """Household response."""

    id: uuid.UUID
    name: str
    timezone: str
    created_at: datetime

    class Config:
        from_attributes = True


class HouseholdMemberResponse(BaseModel):
    """Household member response."""

    id: uuid.UUID
    household_id: uuid.UUID
    user_id: uuid.UUID
    role: str
    joined_at: datetime

    class Config:
        from_attributes = True