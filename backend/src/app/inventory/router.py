"""Inventory router."""

import uuid
from datetime import date
from decimal import Decimal
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_household_id, get_current_household_member_id
from app.common.pagination import PaginationParams
from app.database import get_db
from app.inventory.schemas import (
    InventoryItemCreate,
    InventoryItemResponse,
    InventoryItemUpdate,
    InventoryItemListResponse,
)
from app.inventory.service import InventoryService

router = APIRouter(prefix="/inventory-items", tags=["Inventory"])


async def get_inventory_service(db: AsyncSession = Depends(get_db)) -> InventoryService:
    return InventoryService(db)


@router.post("", response_model=InventoryItemResponse, status_code=status.HTTP_201_CREATED)
async def create_inventory_item(
    data: InventoryItemCreate,
    household_id: uuid.UUID = Depends(get_current_household_id),
    member_id: uuid.UUID = Depends(get_current_household_member_id),
    service: InventoryService = Depends(get_inventory_service),
):
    """Create a new inventory item."""
    return await service.create(household_id, member_id, data)


@router.get("", response_model=InventoryItemListResponse)
async def list_inventory_items(
    category: Optional[str] = Query(None, description="Filter by category key"),
    storage_location_id: Optional[uuid.UUID] = Query(None, description="Filter by storage location ID"),
    limit: int = Query(50, ge=1, le=100),
    cursor: Optional[str] = Query(None, description="Pagination cursor"),
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: InventoryService = Depends(get_inventory_service),
):
    """List inventory items with pagination and optional filters."""
    pagination = PaginationParams(limit=limit, cursor=cursor)
    items, next_token = await service.list(household_id, category, storage_location_id, pagination)
    return InventoryItemListResponse(items=items, next_page_token=next_token)


@router.get("/{item_id}", response_model=InventoryItemResponse)
async def get_inventory_item(
    item_id: uuid.UUID,
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: InventoryService = Depends(get_inventory_service),
):
    """Get a single inventory item by ID."""
    item = await service.get(household_id, item_id)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inventory item not found",
        )
    return item


@router.patch("/{item_id}", response_model=InventoryItemResponse)
async def update_inventory_item(
    item_id: uuid.UUID,
    data: InventoryItemUpdate,
    household_id: uuid.UUID = Depends(get_current_household_id),
    member_id: uuid.UUID = Depends(get_current_household_member_id),
    service: InventoryService = Depends(get_inventory_service),
):
    """Update an inventory item."""
    item = await service.update(household_id, member_id, item_id, data)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inventory item not found",
        )
    return item


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_inventory_item(
    item_id: uuid.UUID,
    household_id: uuid.UUID = Depends(get_current_household_id),
    member_id: uuid.UUID = Depends(get_current_household_member_id),
    service: InventoryService = Depends(get_inventory_service),
):
    """Delete an inventory item."""
    deleted = await service.delete(household_id, member_id, item_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inventory item not found",
        )