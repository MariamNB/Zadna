"""Inventory service."""

import uuid
from datetime import date, datetime, timezone
from decimal import Decimal
from typing import Optional, List

from sqlalchemy import select, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.inventory.models import InventoryItem
from app.inventory.schemas import InventoryItemCreate, InventoryItemUpdate, InventoryItemResponse
from app.storage.models import StorageLocation
from app.reference.models import Category, Unit
from app.common.exceptions import NotFoundError, ValidationError
from app.common.unicode import normalize_nfc
from app.common.pagination import PaginationParams, create_pagination_response, Cursor
from app.audit.service import AuditService


class InventoryService:
    """Inventory service."""

    def __init__(self, session: AsyncSession):
        self.session = session
        self.audit_service = AuditService(session)

    async def create(
        self,
        household_id: uuid.UUID,
        member_id: uuid.UUID,
        data: InventoryItemCreate,
    ) -> InventoryItem:
        """Create a new inventory item."""
        # Validate category exists
        stmt = select(Category).where(Category.key == data.category_key, Category.is_active == True)
        category = await self.session.scalar(stmt)
        if not category:
            raise ValidationError(f"Unknown category: {data.category_key}", code="UNKNOWN_CATEGORY")

        # Validate unit exists
        stmt = select(Unit).where(Unit.key == data.unit_key, Unit.is_active == True)
        unit = await self.session.scalar(stmt)
        if not unit:
            raise ValidationError(f"Unknown unit: {data.unit_key}", code="UNKNOWN_UNIT")

        # Validate storage location exists and belongs to household
        stmt = select(StorageLocation).where(
            StorageLocation.id == data.storage_location_id,
            StorageLocation.household_id == household_id,
        )
        storage_location = await self.session.scalar(stmt)
        if not storage_location:
            raise ValidationError("Invalid storage location", code="INVALID_STORAGE_LOCATION")

        # Validate quantity > 0
        if data.quantity <= 0:
            raise ValidationError("Quantity must be greater than zero", code="INVALID_QUANTITY")

        # Validate notes length
        if data.notes and len(data.notes) > 500:
            raise ValidationError("Notes must not exceed 500 characters", code="NOTES_TOO_LONG")

        # Set date_added default
        date_added = data.date_added or date.today()

        # Create item
        item = InventoryItem(
            household_id=household_id,
            name=data.name,
            category_key=data.category_key,
            quantity=data.quantity,
            unit_key=data.unit_key,
            storage_location_id=data.storage_location_id,
            prepared_at=data.prepared_at,
            frozen_at=data.frozen_at,
            opened_at=data.opened_at,
            expires_at=data.expires_at,
            is_homemade=data.is_homemade,
            status=data.status,
            date_added=date_added,
            notes=data.notes,
            created_by=member_id,
            updated_by=member_id,
        )
        self.session.add(item)
        await self.session.flush()

        # Audit log for create
        await self.audit_service.log_create(
            household_id=household_id,
            actor_user_id=member_id,
            entity_type="inventory_item",
            entity_id=item.id,
            metadata=self._item_to_dict(item),
        )

        await self.session.refresh(item)
        return item

    async def get(
        self,
        household_id: uuid.UUID,
        item_id: uuid.UUID,
    ) -> Optional[InventoryItem]:
        """Get inventory item by ID (household-scoped)."""
        stmt = (
            select(InventoryItem)
            .where(
                InventoryItem.id == item_id,
                InventoryItem.household_id == household_id,
            )
            .options(
                selectinload(InventoryItem.category),
                selectinload(InventoryItem.unit),
                selectinload(InventoryItem.storage_location),
            )
        )
        return await self.session.scalar(stmt)

    async def list(
        self,
        household_id: uuid.UUID,
        category: Optional[str] = None,
        storage_location_id: Optional[uuid.UUID] = None,
        pagination: Optional[PaginationParams] = None,
    ) -> tuple[List[InventoryItem], Optional[str]]:
        """List inventory items with optional filters and pagination."""
        stmt = (
            select(InventoryItem)
            .where(InventoryItem.household_id == household_id)
            .options(
                selectinload(InventoryItem.category),
                selectinload(InventoryItem.unit),
                selectinload(InventoryItem.storage_location),
            )
        )

        # Apply filters
        if category:
            stmt = stmt.where(InventoryItem.category_key == category)
        if storage_location_id:
            stmt = stmt.where(InventoryItem.storage_location_id == storage_location_id)

        # Order by created_at DESC, id for stable pagination
        stmt = stmt.order_by(InventoryItem.created_at.desc(), InventoryItem.id)

        if pagination:
            if pagination.cursor:
                cursor = Cursor.decode(pagination.cursor)
                cursor_created_at = datetime.fromisoformat(cursor.created_at)
                stmt = stmt.where(
                    or_(
                        InventoryItem.created_at < cursor_created_at,
                        and_(
                            InventoryItem.created_at == cursor_created_at,
                            InventoryItem.id < uuid.UUID(cursor.id),
                        ),
                    )
                )
            stmt = stmt.limit(pagination.limit + 1)  # Fetch one extra to check if more

        result = await self.session.scalars(stmt)
        items = list(result.all())

        has_more = False
        if pagination and len(items) > pagination.limit:
            has_more = True
            items = items[:pagination.limit]

        next_token = None
        if has_more and items:
            last = items[-1]
            cursor = Cursor(
                created_at=last.created_at.isoformat(),
                id=str(last.id),
            )
            next_token = cursor.encode()

        return items, next_token

    async def update(
        self,
        household_id: uuid.UUID,
        member_id: uuid.UUID,
        item_id: uuid.UUID,
        data: InventoryItemUpdate,
    ) -> Optional[InventoryItem]:
        """Update inventory item."""
        item = await self.get(household_id, item_id)
        if not item:
            return None

        # Capture before state for audit
        before_state = self._item_to_dict(item)

        # Validate and apply updates
        if data.name is not None:
            if not data.name.strip():
                raise ValidationError("Name cannot be empty", code="EMPTY_NAME")
            item.name = data.name
            # name_normalized is set automatically via __init__

        if data.category_key is not None:
            stmt = select(Category).where(Category.key == data.category_key, Category.is_active == True)
            category = await self.session.scalar(stmt)
            if not category:
                raise ValidationError(f"Unknown category: {data.category_key}", code="UNKNOWN_CATEGORY")
            item.category_key = data.category_key

        if data.quantity is not None:
            if data.quantity <= 0:
                raise ValidationError("Quantity must be greater than zero", code="INVALID_QUANTITY")
            item.quantity = data.quantity

        if data.unit_key is not None:
            stmt = select(Unit).where(Unit.key == data.unit_key, Unit.is_active == True)
            unit = await self.session.scalar(stmt)
            if not unit:
                raise ValidationError(f"Unknown unit: {data.unit_key}", code="UNKNOWN_UNIT")
            item.unit_key = data.unit_key

        if data.storage_location_id is not None:
            stmt = select(StorageLocation).where(
                StorageLocation.id == data.storage_location_id,
                StorageLocation.household_id == household_id,
            )
            storage_location = await self.session.scalar(stmt)
            if not storage_location:
                raise ValidationError("Invalid storage location", code="INVALID_STORAGE_LOCATION")
            item.storage_location_id = data.storage_location_id

        if data.prepared_at is not None:
            item.prepared_at = data.prepared_at
        if data.frozen_at is not None:
            item.frozen_at = data.frozen_at
        if data.opened_at is not None:
            item.opened_at = data.opened_at
        if data.expires_at is not None:
            item.expires_at = data.expires_at
        if data.is_homemade is not None:
            item.is_homemade = data.is_homemade
        if data.status is not None:
            item.status = data.status
        if data.date_added is not None:
            item.date_added = data.date_added
        if data.notes is not None:
            if len(data.notes) > 500:
                raise ValidationError("Notes must not exceed 500 characters", code="NOTES_TOO_LONG")
            item.notes = data.notes

        item.updated_by = member_id
        await self.session.flush()

        # Audit log for update
        after_state = self._item_to_dict(item)
        await self.audit_service.log_update(
            household_id=household_id,
            actor_user_id=member_id,
            entity_type="inventory_item",
            entity_id=item.id,
            metadata={"before": before_state, "after": after_state},
        )

        await self.session.refresh(item)
        return item

    async def delete(
        self,
        household_id: uuid.UUID,
        member_id: uuid.UUID,
        item_id: uuid.UUID,
    ) -> bool:
        """Delete inventory item with audit log."""
        item = await self.get(household_id, item_id)
        if not item:
            return False

        # Capture full snapshot for audit
        snapshot = self._item_to_dict(item)

        # Audit log for delete (same transaction)
        await self.audit_service.log_delete(
            household_id=household_id,
            actor_user_id=member_id,
            entity_type="inventory_item",
            entity_id=item.id,
            metadata=snapshot,
        )

        # Delete the item
        await self.session.delete(item)
        await self.session.flush()
        return True

    def _item_to_dict(self, item: InventoryItem) -> dict:
        """Convert inventory item to dictionary for audit logging."""
        return {
            "name": item.name,
            "category_key": item.category_key,
            "quantity": str(item.quantity),
            "unit_key": item.unit_key,
            "storage_location_id": str(item.storage_location_id),
            "prepared_at": item.prepared_at.isoformat() if item.prepared_at else None,
            "frozen_at": item.frozen_at.isoformat() if item.frozen_at else None,
            "opened_at": item.opened_at.isoformat() if item.opened_at else None,
            "expires_at": item.expires_at.isoformat() if item.expires_at else None,
            "is_homemade": item.is_homemade,
            "status": item.status,
            "date_added": item.date_added.isoformat() if item.date_added else None,
            "notes": item.notes,
            "created_at": item.created_at.isoformat(),
            "updated_at": item.updated_at.isoformat(),
        }