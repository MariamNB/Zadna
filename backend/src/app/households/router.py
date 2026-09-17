"""Household router."""

import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_household_id, get_current_household_member_id
from app.households.schemas import HouseholdMemberResponse, HouseholdResponse
from app.households.service import HouseholdService
from app.database import get_db

router = APIRouter(prefix="/household", tags=["Households"])


async def get_household_service(db: AsyncSession = Depends(get_db)) -> HouseholdService:
    return HouseholdService(db)


@router.get("", response_model=HouseholdResponse)
async def get_household(
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: HouseholdService = Depends(get_household_service),
):
    """Get current household info."""
    household = await service.get_household(household_id)
    if not household:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Household not found",
        )
    return household


@router.get("/members", response_model=List[HouseholdMemberResponse])
async def list_household_members(
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: HouseholdService = Depends(get_household_service),
):
    """List all members of the current household."""
    members = await service.list_members(household_id)
    return members