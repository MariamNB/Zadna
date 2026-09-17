"""Household service."""

import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.households.models import Household, HouseholdMember
from app.households.schemas import HouseholdResponse, HouseholdMemberResponse
from app.storage.models import StorageLocation


class HouseholdService:
    """Household service."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_household_for_user(self, user_id: uuid.UUID) -> Household:
        """Create household with owner membership and default storage locations."""
        household = Household(
            name=f"User's Household",
            timezone="UTC",
        )
        self.session.add(household)
        await self.session.flush()

        # Create membership with owner role
        membership = HouseholdMember(
            household_id=household.id,
            user_id=user_id,
            role="owner",
        )
        self.session.add(membership)
        await self.session.flush()

        # Create default storage locations
        default_locations = [
            StorageLocation(
                household_id=household.id,
                name="Fridge",
                type="fridge",
                sort_order=1,
                created_by=membership.id,
                updated_by=membership.id,
            ),
            StorageLocation(
                household_id=household.id,
                name="Freezer",
                type="freezer",
                sort_order=2,
                created_by=membership.id,
                updated_by=membership.id,
            ),
            StorageLocation(
                household_id=household.id,
                name="Pantry",
                type="pantry",
                sort_order=3,
                created_by=membership.id,
                updated_by=membership.id,
            ),
        ]
        for loc in default_locations:
            self.session.add(loc)

        await self.session.flush()
        return household

    async def get_household(self, household_id: uuid.UUID) -> Optional[Household]:
        """Get household by ID."""
        stmt = select(Household).where(Household.id == household_id)
        return await self.session.scalar(stmt)

    async def get_household_by_member_id(self, member_id: uuid.UUID) -> Optional[Household]:
        """Get household by member ID."""
        stmt = (
            select(Household)
            .join(HouseholdMember, Household.id == HouseholdMember.household_id)
            .where(HouseholdMember.id == member_id)
        )
        return await self.session.scalar(stmt)

    async def list_members(self, household_id: uuid.UUID) -> list[HouseholdMember]:
        """List all members of a household."""
        stmt = (
            select(HouseholdMember)
            .where(HouseholdMember.household_id == household_id)
            .order_by(HouseholdMember.joined_at)
        )
        result = await self.session.scalars(stmt)
        return list(result.all())