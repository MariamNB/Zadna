"""Storage location router."""

import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_household_id, get_current_household_member_id
from app.common.pagination import PaginationParams
from app.database import get_db
from app.storage.schemas import StorageLocationCreate, StorageLocationResponse, StorageLocationUpdate
from app.storage.service import StorageService

router = APIRouter(prefix="/storage-locations", tags=["Storage Locations"])


async def get_storage_service(db: AsyncSession = Depends(get_db)) -> StorageService:
    return StorageService(db)


@router.post("", response_model=StorageLocationResponse, status_code=status.HTTP_201_CREATED)
async def create_storage_location(
    data: StorageLocationCreate,
    household_id: uuid.UUID = Depends(get_current_household_id),
    member_id: uuid.UUID = Depends(get_current_household_member_id),
    service: StorageService = Depends(get_storage_service),
):
    """Create a new storage location."""
    return await service.create(household_id, member_id, data)


@router.get("", response_model=List[StorageLocationResponse])
async def list_storage_locations(
    parent_id: Optional[uuid.UUID] = Query(None, description="Filter by parent location (null for top-level)"),
    limit: int = Query(50, ge=1, le=100),
    cursor: Optional[str] = Query(None, description="Pagination cursor"),
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: StorageService = Depends(get_storage_service),
):
    """List storage locations for the current household."""
    pagination = PaginationParams(limit=limit, cursor=cursor)
    locations, next_token = await service.list(household_id, parent_id, pagination)
    return locations


@router.get("/{location_id}", response_model=StorageLocationResponse)
async def get_storage_location(
    location_id: uuid.UUID,
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: StorageService = Depends(get_storage_service),
):
    """Get a storage location by ID."""
    location = await service.get(household_id, location_id)
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Storage location not found",
        )
    return location


@router.patch("/{location_id}", response_model=StorageLocationResponse)
async def update_storage_location(
    location_id: uuid.UUID,
    data: StorageLocationUpdate,
    household_id: uuid.UUID = Depends(get_current_household_id),
    member_id: uuid.UUID = Depends(get_current_household_member_id),
    service: StorageService = Depends(get_storage_service),
):
    """Update a storage location."""
    location = await service.update(household_id, location_id, member_id, data)
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Storage location not found",
        )
    return location


@router.delete("/{location_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_storage_location(
    location_id: uuid.UUID,
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: StorageService = Depends(get_storage_service),
):
    """Delete a storage location (fails if contains items or children)."""
    deleted = await service.delete(household_id, location_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Storage location not found",
        )