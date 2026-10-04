"""Household schemas."""

import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field
from typing import Literal


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
    email: str = ""

    class Config:
        from_attributes = True


class HouseholdMembershipResponse(HouseholdResponse):
    role: str
    member_id: uuid.UUID


class HouseholdUpdate(BaseModel):
    name: str = Field(min_length=1, max_length=100)


class InvitationCreate(BaseModel):
    email: EmailStr
    role: Literal["admin", "member"] = "member"


class InvitationResponse(BaseModel):
    id: uuid.UUID
    household_id: uuid.UUID
    household_name: str
    email: str
    role: str
    status: str
    expires_at: datetime


class MemberRoleUpdate(BaseModel):
    role: Literal["admin", "member"]
