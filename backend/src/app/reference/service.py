"""Reference data service."""

from typing import List

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.reference.models import Category, Unit
from app.reference.schemas import LocalizedLabel, ReferenceDataResponse


class ReferenceService:
    """Reference data service."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all_categories(self) -> List[LocalizedLabel]:
        """Get all active categories."""
        stmt = select(Category).where(Category.is_active == True).order_by(Category.sort_order)
        result = await self.session.scalars(stmt)
        categories = result.all()
        return [
            LocalizedLabel(key=c.key, labels=c.labels, sort_order=c.sort_order, is_active=c.is_active)
            for c in categories
        ]

    async def get_all_units(self) -> List[LocalizedLabel]:
        """Get all active units."""
        stmt = select(Unit).where(Unit.is_active == True).order_by(Unit.sort_order)
        result = await self.session.scalars(stmt)
        units = result.all()
        return [
            LocalizedLabel(key=u.key, labels=u.labels, sort_order=u.sort_order, is_active=u.is_active)
            for u in units
        ]

    async def get_reference_data(self) -> ReferenceDataResponse:
        """Get all reference data."""
        categories = await self.get_all_categories()
        units = await self.get_all_units()
        return ReferenceDataResponse(categories=categories, units=units)