"""Storage location service."""

import uuid
from typing import Optional, List

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.storage.models import StorageLocation
from app.storage.schemas import StorageLocationCreate, StorageLocationUpdate, StorageLocationResponse
from app.common.pagination import PaginationParams, create_pagination_response, Cursor


class StorageService:
    """Storage location service."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, household_id: uuid.UUID, member_id: uuid.UUID, data: StorageLocationCreate) -> StorageLocation:
        """Create a new storage location."""
        # Verify parent exists and belongs to household if provided
        if data.parent_id:
            stmt = select(StorageLocation).where(
                StorageLocation.id == data.parent_id,
                StorageLocation.household_id == household_id,
            )
            parent = await self.session.scalar(stmt)
            if not parent:
                from app.common.exceptions import NotFoundError
                raise NotFoundError("Parent location not found", code="PARENT_NOT_FOUND")

        location = StorageLocation(
            household_id=household_id,
            name=data.name,
            type=data.type,
            parent_id=data.parent_id,
            sort_order=data.sort_order,
            created_by=member_id,
            updated_by=member_id,
        )
        self.session.add(location)
        await self.session.flush()
        await self.session.refresh(location)
        return location

    async def get(self, household_id: uuid.UUID, location_id: uuid.UUID) -> Optional[StorageLocation]:
        """Get storage location by ID (household-scoped)."""
        stmt = select(StorageLocation).where(
            StorageLocation.id == location_id,
            StorageLocation.household_id == household_id,
        )
        return await self.session.scalar(stmt)

    async def list(
        self,
        household_id: uuid.UUID,
        parent_id: Optional[uuid.UUID] = None,
        pagination: Optional[PaginationParams] = None,
    ) -> tuple[List[StorageLocation], Optional[str]]:
        """List storage locations for household with optional parent filter."""
        stmt = select(StorageLocation).where(
            StorageLocation.household_id == household_id,
        )

        if parent_id is not None:
            stmt = stmt.where(StorageLocation.parent_id == parent_id)
        else:
            stmt = stmt.where(StorageLocation.parent_id.is_(None))

        stmt = stmt.order_by(StorageLocation.sort_order, StorageLocation.created_at)

        if pagination:
            # Simple limit/offset for storage locations (no cursor needed for small sets)
            stmt = stmt.limit(pagination.limit)

        result = await self.session.scalars(stmt)
        locations = list(result.all())

        # For storage locations, we don't typically need cursor pagination
        # but we'll return a token if there are more
        next_token = None
        if pagination and len(locations) >= pagination.limit:
            last = locations[-1]
            cursor = Cursor(
                created_at=last.created_at.isoformat(),
                id=str(last.id),
            )
            next_token = cursor.encode()

        return locations, next_token

    async def update(
        self,
        household_id: uuid.UUID,
        location_id: uuid.UUID,
        member_id: uuid.UUID,
        data: StorageLocationUpdate,
    ) -> Optional[StorageLocation]:
        """Update storage location."""
        location = await self.get(household_id, location_id)
        if not location:
            return None

        # Verify parent exists and belongs to household if provided
        if data.parent_id is not None:
            if data.parent_id == location_id:
                from app.common.exceptions import ValidationError
                raise ValidationError("Cannot set parent to self", code="INVALID_PARENT")

            stmt = select(StorageLocation).where(
                StorageLocation.id == data.parent_id,
                StorageLocation.household_id == household_id,
            )
            parent = await self.session.scalar(stmt)
            if not parent:
                from app.common.exceptions import NotFoundError
                raise NotFoundError("Parent location not found", code="PARENT_NOT_FOUND")

        if data.name is not None:
            location.name = data.name
        if data.type is not None:
            location.type = data.type
        if data.parent_id is not None:
            location.parent_id = data.parent_id
        if data.sort_order is not None:
            location.sort_order = data.sort_order

        location.updated_by = member_id
        await self.session.flush()
        await self.session.refresh(location)
        return location

    async def delete(self, household_id: uuid.UUID, location_id: uuid.UUID) -> bool:
        """Delete storage location (fails if has children or items)."""
        location = await self.get(household_id, location_id)
        if not location:
            return False

        # Check for children
        stmt = select(StorageLocation).where(StorageLocation.parent_id == location_id)
        children = await self.session.scalars(stmt)
        if children.first():
            from app.common.exceptions import ConflictError
            raise ConflictError("Location has child locations", code="HAS_CHILDREN")

        # Check for inventory items
        from app.inventory.models import InventoryItem
        stmt = select(InventoryItem).where(InventoryItem.storage_location_id == location_id)
        items = await self.session.scalars(stmt)
        if items.first():
            from app.common.exceptions import ConflictError
            raise ConflictError("Location has inventory items", code="HAS_ITEMS")

        await self.session.delete(location)
        await self.session.flush()
        return True